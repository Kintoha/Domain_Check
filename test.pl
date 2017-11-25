#!/usr/bin/perl 
use Modern::Perl;
use Data::Printer;
#use Array::Utils qw(:all);

say "Введите имя домена";
my $domain_name = <STDIN>;
chomp($domain_name);
$domain_name = lc($domain_name);

my $domain_zone; # Зона домена
my @domain_status; # Массив статусов домена
my @domain_dns_whois; # Массив DNS серверов из whois домена

# Получаем whois домена
my $whois = `whois $domain_name` or die "Не удается запустить whois для домена $domain_name: $!";

# Получаем массив строк из whois
my @array_line_whois = split /\n/, $whois;

# Определение зоны домена
if ($domain_name =~ /.* \. (\w+)/x) { $domain_zone = $1; }

if ($domain_zone eq "ru" || $domain_zone eq "su" || $domain_zone eq "рф" ) {
	my %whois_variable = get_whois_ru();
	p %whois_variable;

	p @domain_dns_whois;
}
else {
	my %whois_variable = get_whois_com();
	p %whois_variable;

	p @domain_status;

	p @domain_dns_whois;
}

# Статусы международных доменов:
#addPeriod
#autoRenewPeriod
#inactive
#ok
#pendingCreate
#pendingDelete
#pendingRenew
#pendingRestore
#pendingTransfer
#pendingUpdate
#redemptionPeriod
#renewPeriod
#serverDeleteProhibited
#serverHold
#serverRenewProhibited
#serverTransferProhibited
#serverUpdateProhibited
#transferPeriod
#clientDeleteProhibited
#clientHold
#clientRenewProhibited
#clientTransferProhibited
#clientUpdateProhibited

sub get_whois_com {

	@domain_dns_whois = check_name_server_com();
	@domain_status = check_status_com();
	my %whois_variable = (
		exp_date => check_exp_date_com(),
		created_date => check_create_date_com(),
		registrar => check_registrar_com(),
		updated_date => check_updated_date_com(),
		);
	return %whois_variable;
}

# Функция определяет статусы международного домена
sub check_status_com {
	foreach my $line (@array_line_whois) {
		if ($line =~ / .* Status: \s* (\w+) .* /x) { push(@domain_status, $1); }
	}
	return @domain_status;
}

sub check_name_server_com {
	foreach my $line (@array_line_whois) {
		if ($line =~ / .* Name .* Server: \s* (.+) \s* /x) { push(@domain_dns_whois, $1); }
	}
	return @domain_dns_whois;
}

sub check_exp_date_com {
	if ($whois =~ / \s* Registry \s Expiry \s Date: \s* (\d{4})-(\d{2})-(\d{2}) .* /x) {return "$1-$2-$3"; }
}

sub check_create_date_com {
	if ($whois =~ / \s* Creation \s Date: \s* (\d{4})-(\d{2})-(\d{2}) .* /x) {return "$1-$2-$3"; }
}

sub check_registrar_com {
	if ($whois =~ / \s* Registrar: \s* (.*) /x) {return "$1"; }
}

sub check_updated_date_com {
	if ($whois =~ / \s* Updated \s Date: \s* (\d{4})-(\d{2})-(\d{2}) .* /x) {return "$1-$2-$3"; }
}

sub check_delegate_com {
	foreach my $status (@domain_status) {
		if ( $status eq "clientHold" ) { return 0; }
		elsif ( $status eq "serverHold" ) { return 0; }
		elsif ( $status eq "inactive" ) { return 0; }
	}
	return 1;
}

sub check_transfer_com {
	foreach my $status (@domain_status) {
		if ( $status eq "clientTransferProhibited" ) { return 0; }
		elsif ( $status eq "serverTransferProhibited" ) { return 0; }
	}
	return 1;
}

my %all_statuses = ( inactive => "Домен не делегирован",
ok => "Домен не имеет каких либо блокировок или выполняемых процессов",
pendingCreate => "Домен в процессе регистрации",
pendingDelete => "Домен в процессе удаления",
pendingRenew => "Домен в процессе продления",
pendingRestore => "Домен в процессе восстановления",
pendingTransfer => "Домен в процессе переноса к другому регистратору",
pendingUpdate => "Домен в процессе обновления",
redemptionPeriod => "Домен в периоде возможного восстановления",
renewPeriod => "Домен в периоде возможного продления",
serverDeleteProhibited => "Домен запрещён к удалению реестром зоны",
serverHold => "Домен снят с делегирования реестром зоны",
serverRenewProhibited => "Домен запрещён к продлению реестром зоны",
serverTransferProhibited => "Домен запрещён к переносу реестром зоны",
serverUpdateProhibited => "Домен запрещён к обновлению реестром зоны",
transferPeriod => "Домен был успешно перенесён к новому регистратору и имеет льготный период при удалении",
clientDeleteProhibited => "Домен запрещён к удалению регистратором",
clientHold => "Домен снят с делегирования регистратором",
clientRenewProhibited => "Домен запрещён к продлению регистратором",
clientTransferProhibited => "Домен запрещён к переносу регистратором",
clientUpdateProhibited  => "Домен запрещён к обновлению регистратором",
);

statuses_com();

sub statuses_com {
	foreach my $status_domain (@domain_status) {
		say $all_statuses{$status_domain};
	}
}

sub get_whois_ru {

	@domain_dns_whois = check_name_servers_ru();
	my %whois_variable = (
		exp_date => check_exp_date_ru(),
		delegated => check_delegate_ru(),
		deleted => check_deleted_ru(),
		registred => check_registred_ru(),
		created_date => check_create_date_ru(),
		registrar => check_registrar_ru(),
		free_date => check_free_date_ru(),
		person => check_person_ru(),
		);
	return %whois_variable;
}

# Функция определяет paid-till(exp_date) для .RU/.SU/.РФ
sub check_exp_date_ru {
	if ($whois =~ / paid-till: \s* (\d{4})-(\d{2})-(\d{2}) .* /x) {return "$1-$2-$3"; }
}

# Функция определяет делегирование для .RU/.SU/.РФ
sub check_delegate_ru {
	if ($whois =~ / .* DELEGATED .* /x) {return "Делегирован"; }
	elsif ($whois =~ / .* NOT DELEGATED .* /x) {return "Не делегирован"; }
}

# Функция определяет удаление .RU/.SU/.РФ
sub check_deleted_ru {
	if ($whois =~ / .* pendingDelete .* /x) {return "Домен в процессе удаления"; }
	return "Статуса удаления нет";
}

sub check_registred_ru {
	if ($whois =~ / .* REGISTERED .* /x) {return "Зарегистрирован"; }
}

sub check_create_date_ru {
	if ($whois =~ / created: \s* (\d{4})-(\d{2})-(\d{2}) .* /x) {return "$1-$2-$3"; }
}

sub check_registrar_ru {
	if ($whois =~ / registrar: \s* (.*) .* /x) {return $1; }
}

sub check_free_date_ru {
	if ($whois =~ / free-date: \s* (\d{4})-(\d{2})-(\d{2}) .* /x) {return "$1-$2-$3"; }
}

sub check_person_ru {
	if ($whois =~ / person: \s* (.*) .* /x) {return $1; }
	elsif ($whois =~ / org: \s* (.*) .* /x) {return $1; }
}

sub check_name_servers_ru {
	foreach my $line (@array_line_whois) {
		if ($line =~ / nserver: \s* (.+) /x) {
			my @array_dns_param = split (/ /, lc($1)); # Массив содержащий ДНС сервер и его IP адреса (если есть)
			push(@domain_dns_whois, $array_dns_param[0]);
		}
	}
	return @domain_dns_whois;
}


# Получаем неавторитативный dig any домена
my $dig_any_output = `dig $domain_name any +noall +answer` or die "Не удается запустить dig для домена $domain_name: $!";
my @array_line_dig = split /\n/, $dig_any_output;

my @domain_dns_dig; # Массив DNS серверов неавторитативного ответа dig
my @domain_mx_dig; # Массив MX записей неавторитативного ответа dig
my @domain_a_dig; # Массив A записей неавторитативного ответа dig
my @domain_txt_dig; # Массив TXT записей неавторитативного ответа dig
my @domain_aaaa_dig; # Массив AAAA записей неавторитативного ответа dig

get_dig();

sub get_dig {
	@domain_dns_dig = check_dig_ns();
	p @domain_dns_dig;

	@domain_mx_dig = check_dig_mx();
	p @domain_mx_dig;

	@domain_a_dig = check_dig_a();
	p @domain_a_dig;

	@domain_txt_dig = check_dig_txt();
	p @domain_txt_dig;

	@domain_aaaa_dig = check_dig_aaaa();
	p @domain_aaaa_dig;
}

sub check_dig_ns {
	foreach my $line (@array_line_dig) {
		if ($line =~ / .+ IN \s+ NS \s+ (.+)/x) { push(@domain_dns_dig, $1); }
	}
	return @domain_dns_dig;
}

sub check_dig_mx {
	foreach my $line (@array_line_dig) {
		if ($line =~ / .+ IN \s+ MX \s+ (.+)/x) { push(@domain_mx_dig, $1); }
	}
	return @domain_mx_dig;
}

sub check_dig_a {
	foreach my $line (@array_line_dig) {
		if ($line =~ / .+ IN \s+ A \s+ (.+)/x) { push(@domain_a_dig, $1); }
	}
	return @domain_a_dig;
}

sub check_dig_txt {
	foreach my $line (@array_line_dig) {
		if ($line =~ / .+ IN \s+ TXT \s+ (.+)/x) { push(@domain_txt_dig, $1); }
	}
	return @domain_txt_dig;
}

sub check_dig_aaaa {
	foreach my $line (@array_line_dig) {
		if ($line =~ / .+ IN \s+ AAAA \s+ (.+)/x) { push(@domain_aaaa_dig, $1); }
	}
	return @domain_aaaa_dig;
}

#compare_DNS_whois_and_dig();

sub compare_DNS_whois_and_dig {
	# symmetric difference
    #my @diff = array_diff(@domain_dns_whois, @domain_dns_dig);
    #say "symmetric difference:";
    #p @diff;
}
