#!/bin/bash

#Get current date
today=`date +%Y-%m-%d_%H:%M:%S`
#Get current octotiger commit
basedir=`pwd`
cd src/octotiger/src
current_commit=`git rev-parse HEAD`
cd $basedir
#Get current HPX commit
cd src/hpx
current_commit_hpx=`git rev-parse HEAD`
cd $basedir
#Create Test folder
mkdir "KNL-run-$today"
cd "KNL-run-$today"
# Create result files
echo "# Octotiger commit: $current_commit " > computation_time_results.txt
echo "# HPX commit: $current_commit_hpx " >> computation_time_results.txt
echo "# Date of run $today" >> computation_time_results.txt
echo "# Measuring computation time" >> computation_time_results.txt
echo "#" >> computation_time_results.txt
echo "#Number HPX threads,All off,m2m on,m2p on,p2p on,p2m on,All on,All on except p2m" >> computation_time_results.txt
echo "# Octotiger commit: $current_commit " > total_time_results.txt
echo "# HPX commit: $current_commit_hpx " >> total_time_results.txt
echo "# Date of run $today" >> total_time_results.txt
echo "# Measuring total time" >> total_time_results.txt
echo "#" >> total_time_results.txt
echo "#Number HPX threads,All off,m2m on,m2p on,p2p on,p2m on,All on,All on except p2m" >> total_time_results.txt
# Save this version of the script for sanity checks later on
cp ../KNL-test.sh script-copy.txt
# Running tests
for i in `seq 4 4 64`; do
	echo "Running test $i - all off..."
	output1="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=old p2m_kernel_type=old m2m_kernel_type=old m2p_kernel_type=old)"
	echo "Running test $i - m2m on..."
	output2="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=old p2m_kernel_type=old m2m_kernel_type=soa_cpu m2p_kernel_type=old)"
	echo "Running test $i - m2p on..."
	output3="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=old p2m_kernel_type=old m2m_kernel_type=old m2p_kernel_type=soa_cpu)"
	echo "Running test $i - p2p on..."
	output4="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=soa_cpu p2m_kernel_type=old m2m_kernel_type=old m2p_kernel_type=old)"
	echo "Running test $i - p2m on..."
	output5="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=old p2m_kernel_type=soa_cpu m2m_kernel_type=old m2p_kernel_type=old)"
	echo "Running test $i - All on..."
	output6="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=soa_cpu p2m_kernel_type=soa_cpu m2m_kernel_type=soa_cpu m2p_kernel_type=soa_cpu)"
	output7="$(./../build-cpu-RelWithDebInfo-jemalloc/octotiger/octotiger -Ihpx.stacks.use_guard_pages=0 -t$i -Disableoutput -Problem=moving_star -Max_level=6 -Odt=0.3 -Stoptime=0.2 -Xscale=20.0 -Omega=0.1 -Stopstep=20 p2p_kernel_type=soa_cpu p2m_kernel_type=old m2m_kernel_type=soa_cpu m2p_kernel_type=soa_cpu)"
	# Clean up results
	clean_output_computational="$i,$(echo "$output1" | grep 'Computation' | sed 's/Computation: //g'),$(echo "$output2" | grep 'Computation' | sed 's/Computation: //g'),$(echo "$output3" | grep 'Computation' | sed 's/Computation: //g'),$(echo "$output4" | grep 'Computation' | sed 's/Computation: //g'),$(echo "$output5" | grep 'Computation' | sed 's/Computation: //g'),$(echo "$output6" | grep 'Computation' | sed 's/Computation: //g'),$(echo "$output7" | grep 'Computation' | sed 's/Computation: //g')" 
	clean_output_total="$i,$(echo "$output1" | grep 'Total' | sed 's/Total: //g'),$(echo "$output2" | grep 'Total' | sed 's/Total: //g'),$(echo "$output3" | grep 'Total' | sed 's/Total: //g'),$(echo "$output4" | grep 'Total' | sed 's/Total: //g'),$(echo "$output5" | grep 'Total' | sed 's/Total: //g'),$(echo "$output6" | grep 'Total' | sed 's/Total: //g'),$(echo "$output7" | grep 'Total' | sed 's/Total: //g')" 
	# Print and save to files >> for appending
	echo "$clean_output_computational" >> "computation_time_results.txt"
	echo "$clean_output_computational"
	echo "$clean_output_total" >> "total_time_results.txt"
	echo "$clean_output_total"
done

# Plot results of computation and store into folder
cp ../plot-knl.plt plot-knl.plt
gnuplot -e "filename='computation_time_results.txt'" -e "outfile='computation_time_scaling.png'" plot-knl.plt
gnuplot -e "filename='total_time_results.txt'" -e "outfile='total_time_scaling.png'" plot-knl.plt
echo "done"
