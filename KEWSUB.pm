package KEWSUB;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $self = {
		JOBNAME => undef,
		BATCHID => undef,
		SCRIPT => undef,
		SCRIPT_ARGS => undef
	};
	bless($self, $class);
}

sub setScript {
	my $self = shift;
	$self->{SCRIPT} = shift;
}

sub setScript_args {
	my $self = shift;
	$self->{SCRIPT_ARGS} = shift;
}

sub setJobname {
	my $self = shift;
	$self->{JOBNAME} = shift;
}

sub setBatchid {
	my $self = shift;
	$self->{BATCHID} = shift;
}

sub run {
	my $self = shift;
	my $localdir = `pwd`;
	chomp $localdir;
	my $batchfile = "$localdir/".$self->{BATCHID};
	open my $batch, ">$batchfile" or die "Could not create $batchfile\n";
	print $batch <<'TOP';
#!/bin/bash
#PBS -c s
#PBS -j oe
#PBS -m ae
TOP
	print $batch '#PBS -N '.$self->{JOBNAME}."\n";
	print $batch <<'REST';
#PBS -M name@emailaddress.com
#PBS -l walltime=05:00:00
#PBS -l pmem=8gb
#PBS -l nodes=1:ppn=1

echo "------------------------------------------------------"
echo " This job is allocated 1 cpu on "
cat $PBS_NODEFILE
echo "------------------------------------------------------"
echo "PBS: Submitted to $PBS_QUEUE@$PBS_O_HOST"
echo "PBS: Working directory is $PBS_O_WORKDIR"
echo "PBS: Job identifier is $PBS_JOBID"
echo "PBS: Job name is $PBS_JOBNAME"
echo "------------------------------------------------------"
 
cd $PBS_O_WORKDIR
source /etc/profile.d/modules.sh
module load grass
REST
	my $fullscript = $self->{SCRIPT}." ".$self->{SCRIPT_ARGS};
	print $batch "$fullscript\n";
	close $batch;
	chmod 0711, $batchfile;
	system "qsub $batchfile";
}

1;
