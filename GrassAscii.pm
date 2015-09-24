package GrassAscii;
use strict;
use warnings;

sub new {
	my $class = shift;
	my $fullpath = shift or die "You must argue a full path\n";
	my $self = {
		FULLPATH => $fullpath,
		NORTH => undef,
		SOUTH => undef,
		EAST => undef,
		WEST => undef,
		ROWS => undef,
		COLS => undef,
		NULL => undef,
		TYPE => 'float',
		MULTIPLIER => 1,
		DECIMAL_PLACES => 2,
		DATA => []
	};
	bless($self, $class);
	return $self;
}

sub write_ascii {
	my $self = shift;
	if (@_) { ($self->{TYPE}, $self->{DECIMAL_PLACES}) = @_ }
	my $dps = $self->{DECIMAL_PLACES};
	open my $output, ">".$self->{FULLPATH} or die "Could not edit/create ".$self->{FULLPATH}."\n";
		foreach my $field qw (NORTH SOUTH EAST WEST ROWS COLS NULL TYPE MULTIPLIER) {
			if (defined($self->{$field})) {
				print $output lc($field).":\t".$self->{$field}."\n";
			}
		}
		foreach my $datarow (@{$self->{DATA}}) {
			my @rowdata = map(sprintf("%.$dps"."f",$_), @$datarow);
			print $output join("\t",@rowdata)."\n";
		}
	close $output;
}

sub read_header {
	my $self = shift;
	open my $input, $self->{FULLPATH} or die "Could not open ".$self->{FULLPATH}."\n";
	while (my $line = <$input>) {
		if ($line =~ /^([a-z]+):(\s*|\t)(\w+)$/) {
			$self->{uc($1)} = $3;
		} else {
			return 1;
		}
	}
	0;
}

sub read_data {
	my $self = shift;
	open my $input, $self->{FULLPATH};
	my @data;
	while (my $row = <$input>) {
		unless ($row =~ /^[a-z]/) {
			my @rowdata = split(/\t|\s/,$row);
			push @data, \@rowdata;
		}
	}
	$self->{DATA} = \@data;
	close $input;
}

1;