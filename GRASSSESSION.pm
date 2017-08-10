package GRASSSESSION;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $self = {
		GISDBASE => undef,
		LOCATION => undef,
		BATCHID => generate_id(),
		COMMAND => '',
		BATCH_FILES => []
	};
	$self->{GISDBASE} = shift if @_;
	bless($self, $class);
	return $self;
}

sub clearCommand {
	my $self = shift;
	$self->{COMMAND} = '';
}

sub addCommand {
	my $self = shift;
	my $command = shift;
	$self->{COMMAND} .= "$command\n";
}

sub setBatchID {
	my $self = shift;
	$self->{BATCHID} = shift;
}

sub getBatchID {
	my $self = shift;
	return $self->{BATCHID};
}

sub setLocation {
	my $self = shift;
	$self->{LOCATION} = shift if @_;
	return $self->{LOCATION};
}

sub setGisdbase {
	my $self = shift;
	$self->{GISDBASE} = shift if @_;
	return $self->{GISDBASE};
}

sub getGisdbase {
	my $self = shift;
	return $self->{GISDBASE};
}

sub DESTROY {
	my $self = shift;
	my $command = "find ".$self->{GISDBASE}." -type d -name '".$self->{BATCHID}."'";
	my @deletes = `$command`;
	chomp @deletes;
	foreach (@deletes) {
		system "rm -rf $_";
	}
	foreach (@{$self->{BATCH_FILES}}) {
		unlink $_;
	}
}

sub generate_id {
	my $suffix = sprintf("%X",time().int(rand(1000)));

	return "M$suffix";
}

sub run {
	my $self = shift;
	my $wd = `pwd`;
	chomp $wd;
	my $batchfile = "$wd/".$self->{BATCHID};
	push @{$self->{BATCH_FILES}}, $batchfile; #for later deletion
	open my $output, ">$batchfile" or die "Couldn't open ".$self->{BATCHID}."\n";
		print $output $self->{COMMAND};
	close $output;
	chmod 0711, $batchfile;
	my $grasspath = $self->{GISDBASE}.'/'.$self->{LOCATION}.'/'.$self->{BATCHID};
	my $command = <<"EOF";
export GRASS_BATCH_JOB=$batchfile
grass64 -c -text $grasspath
EOF
	clearCommand($self);
	return `$command`;
}

1;
