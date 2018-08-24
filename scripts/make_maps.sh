#!/bin/bash
#SBATCH --nodes=32
#SBATCH --ntasks=512
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --job-name 4096Mpc_nb32_13579
#SBATCH --output=4096Mpc_nb32_13579_%j.txt

cd $SLURM_SUBMIT_DIR
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

boxsize=8000
boxsizeot=-`echo $boxsize | awk '{print $1/2}'`
nres=4096


zi=0.0
zf=0.5
nz=23
dz=0.2
i=0

densityfile=Fvec_8Gpc_n4096_nb18_nt16_ics
halofile=../alex_lague_axion/poster_runs/4096Mpc_n4096_all/output/4096Mpc_n4096_nb32_nt8_LCDM_merge.pksc.13579
fluxfile=dFdChi_0545.bin

nchunk=1
binary_only=0

while [ $i -lt $nz ]; do
    zmin=`awk "BEGIN {print $zi+$i*$dz}"`
    zmax=`awk "BEGIN {print $zi+($i+1)*$dz}"`
    zmid=`awk "BEGIN {print ($zmin+$zmax)/2}"`

    cp param_REPLACE param
    sed -i -e 's/ZIREPLACE/'${zi}'/g' param
    sed -i -e 's/ZFREPLACE/'${zmax}'/g' param

    mapnum=1
    mapname=kappa_field_nside4096_zmin$zi\_zmax$zmax\_zsource$zmid
    stdout=logfiles/$mapname.stdout
    stderr=logfiles/$mapname.stderr

    mpirun ./cal-sky/bin/lin2map -P param -v -D $densityfile -C $nchunk -N $nres -B $boxsize -p $boxsize -x $boxsizeot -y $boxsizeot -z $boxsizeot -m $mapnum -o $mapname -b $binary_only -k $zmid 2> $stderr 1> $stdout #-H $halofile
    cp weights.dat weights_kappa_$zmin\_$zmax\.dat

    cp param_REPLACE param
    sed -i -e 's/ZIREPLACE/'${zmin}'/g' param
    sed -i -e 's/ZFREPLACE/'${zmax}'/g' param

    mapnum=16
    mapname=cib_field_nside4096_zmin$zmin\_zmax$zmax
    stdout=logfiles/$mapname.stdout
    stderr=logfiles/$mapname.stderr

    mpirun ./cal-sky/bin/lin2map -P param -v -D $densityfile -C $nchunk -N $nres -B $boxsize -p $boxsize -x $boxsizeot -y $boxsizeot -z $boxsizeot -m $mapnum -o $mapname -b $binary_only 2> $stderr 1> $stdout -F $fluxfile #-H $halofile
    cp weights.dat weights_cib_$zmin\_$zmax\.dat

    i=$(($i+1))
done

