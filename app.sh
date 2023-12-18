#!/bin/bash


max_length=30
memory_data=()
cpu_data=()
individual_cpu_cores_data=()
output_file_ram="memory_graph.txt"
output_file_cpu="cpu_graph.txt"
output_file_cpu_cores="cpu_cores_graph.txt"
update_frequency=0.1



# separating for less confusion 

# RAM
# -----------------------------------------------------

get_memory_usage() {

    used_memory_pages=$(vm_stat | awk '/Pages active/ {print $3}')

    total_memory_pages=$(sysctl -n hw.memsize | awk '{print int($1 / 4096)}')

    memory_usage=$(echo "scale=0; $used_memory_pages * 1000 / $total_memory_pages" | bc)

    if (( $(echo "$memory_usage < 0" | bc -l) )); then
        memory_usage=0
    elif (( $(echo "$memory_usage > 1000" | bc -l) )); then
        memory_usage=1000
    fi

    echo $memory_usage
}



get_memory_usage_gb() {

    memory_gb=$(top -l 1 | awk '/PhysMem/ {print $2}' | sed 's/[A-Za-z]//g')

    total_memory=$(sysctl -n hw.memsize)
    total_memory_gb=$(echo "$total_memory / 1024 / 1024 / 1024" | bc)

    echo "$memory_gb""GB / ""$total_memory_gb""GB"
}

# -----------------------------------------------------



# CPU
# -----------------------------------------------------

get_cpu_usage() {
    cpu_usage=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')

    num_cores=$(sysctl -n hw.ncpu)

    cpu_usage_avg=$(echo "scale=2; $cpu_usage / $num_cores" | bc)

    echo $cpu_usage_avg
}

# -----------------------------------------------------


# Individual CPU Cores
# -----------------------------------------------------

get_individual_cpu_cores_usage() {
    cpu_cores=$(sysctl -n hw.ncpu)
    total_cpu_usage=$(ps -A -o %cpu | awk '{sum+=$1} END {print sum}')
    
    usage_per_core=$(echo "($total_cpu_usage / $cpu_cores) / $cpu_cores " | bc -l)

    cpu_usages=()
    for ((i=0; i<cpu_cores; i++)); do
        cpu_usages+=("$usage_per_core")
    done

    echo "${cpu_usages[@]}"
}

# -----------------------------------------------------


print_color() {
    echo -e "\033[${2}m${1}%\033[0m"
}

print_color_blue() {
    echo -e "\033[0;34m${1}%\033[0m"
}

print_color_red() {
    echo -e "\033[0;31m${1}%\033[0m"
}

print_color_green() {
    echo -e "\033[0;32m${1}%\033[0m"
}

print_color_yellow() {
    echo -e "\033[0;33m${1}%\033[0m"
}


print_color_status() {
    percentage=$1
    if [ $percentage -gt 90 ]; then
        print_color_red $percentage
    elif [ $percentage -gt 70 ]; then
        print_color_yellow $percentage
    else
        print_color_green $percentage 
    fi
}





# RAM
# -----------------------------------------------------

update_graph_ram() {
    > $output_file_ram

    mem_usage_text="Memory Usage:"
    static_spaces=$((35 - ${#mem_usage_text}))
    printf "\033[0;34m%s%*s\033[0m\n" "$mem_usage_text" $static_spaces "" >> $output_file_ram



    for (( i=100; i>=0; i-=10 )); do
        line=""
        current_space_count=30
        

        current_space_count=$(echo "$current_space_count - 1" | bc)

        for usage in "${memory_data[@]}"; do
            int_usage=$(echo "$usage/1" | bc)
            
            if (( int_usage >= i )); then
                line+="*"
                
            else
                line+=" "

            fi


        done

        line="${line%"${line##*[![:space:]]}"}"
        spaces_after_line=$((current_space_count - ${#line}))

        printf "%3d%% |%s%*s\n" $i "$line" $spaces_after_line "" >> $output_file_ram
            

        # printf "%3d%% |%s\n" $i "$line" >> $output_file
    done
    echo "      ------------------------------" >> $output_file_ram
    echo "Time -> Most Recent Data on Right" >> $output_file_ram

    # print_color_status $(printf "%.0f" $memory_usage)
    # printf "$memory_usage_gb"
}

# -----------------------------------------------------



# Individual CPU Cores
# -----------------------------------------------------


update_cpu_cores_usage() {
    > $output_file_cpu_cores

    cpu_usage_text="CPU Core Usage:"
    
    printf "\033[0;34m%s\033[0m\n" "$cpu_usage_text" >> $output_file_cpu_cores

    cpu_usage=($(get_individual_cpu_cores_usage))

    for core_usage in "${cpu_usage[@]}"; do
        if (( $(echo "$core_usage < 1" | bc -l) )); then
            bar_length=1
        else
            bar_length=$(printf "%.0f" $(echo "($core_usage / 100 * 20) + 0.5" | bc -l))
        fi

        printf "[%-${bar_length}s] %5.2f%%\n" $(printf "%-${bar_length}s" | tr ' ' '#') $core_usage >> $output_file_cpu_cores
    done
}
# -----------------------------------------------------





# CPU
# -----------------------------------------------------

update_graph_cpu() {
    > $output_file_cpu

    cpu_usage_text="CPU Usage:"
    static_spaces=$((35 - ${#cpu_usage_text}))
    printf "\033[0;34m%s%*s\033[0m\n" "$cpu_usage_text" $static_spaces "" >> $output_file_cpu
    
    for (( i=100; i>=0; i-=10 )); do
        line=""
        current_space_count=30
        
        current_space_count=$(echo "$current_space_count - 1" | bc)

        for usage in "${cpu_data[@]}"; do
            int_usage=$(echo "$usage/1" | bc)
            
            if (( int_usage >= i )); then
                line+="*"
                
            else
                line+=" "

            fi
        done

        line="${line%"${line##*[![:space:]]}"}"
        spaces_after_line=$((current_space_count - ${#line}))

        printf "%3d%% |%s%*s\n" $i "$line" $spaces_after_line "" >> $output_file_cpu
    done
    echo "      ------------------------------" >> $output_file_cpu
    echo "Time -> Most Recent Data on Right" >> $output_file_cpu
}

# -----------------------------------------------------




while true; do

    # RAM
    memory_usage=$(get_memory_usage)
    memory_usage_gb=$(get_memory_usage_gb)

    memory_data+=("$memory_usage")
    if [ ${#memory_data[@]} -gt $max_length ]; then
        memory_data=("${memory_data[@]:1}")
    fi


    # CPU
    cpu_usage=$(get_cpu_usage)
    cpu_data+=("$cpu_usage")

    if [ ${#cpu_data[@]} -gt $max_length ]; then
        cpu_data=("${cpu_data[@]:1}")
    fi

   


    

    update_cpu_cores_usage
    update_graph_ram
    update_graph_cpu 
    



    clear
    paste $output_file_ram $output_file_cpu $output_file_cpu_cores



    sleep $update_frequency
done
