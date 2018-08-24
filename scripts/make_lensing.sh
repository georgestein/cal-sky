#!/bin/bash
#SBATCH --nodes=32
#SBATCH --ntasks=512
#SBATCH --cpus-per-task=2
#SBATCH --time=10:00:00
#SBATCH --job-name 4096Mlensing
#SBATCH --output=4096lensing_%j.txt

cd /scratch/r/rbond/remim/modified_lenspix/

for i in 2.4;
do
    echo "-----------$i----------"
    zmid=`awk "BEGIN {print $i-0.1}"`
    zmax=`awk "BEGIN {print $i+0.2}"`
    echo "$zmid"
    echo "$zmax"
    python lens.py /scratch/r/rbond/remim/cal_sky_new/maps/kappa/GRF/kappa_field_nside4096_zmin0.0_zmax${i}_zsource${zmid}_kap_2048_2048_GRF.fits /scratch/r/rbond/remim/cal_sky_new/maps/cib/GRF/alm/cib_field_nside4096_zmin${i}_zmax${zmax}_cib_2048_2048_GRF_alm.fits  /scratch/r/rbond/remim/cal_sky_new/maps/phi/kap_zmax${i}_phi_field.fits /scratch/r/rbond/remim/cal_sky_new/maps/lensed/GRF/cib_field_nside2048_zmin${i}_zmax${zmax}_cib_lensed_bGRF.fits -np 40
done
