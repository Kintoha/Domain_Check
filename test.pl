#!/usr/bin/perl 
use Modern::Perl;
use Data::Printer;
#use utf8;

say "Введите имя домена";
my $domain_name = <STDIN>;
chomp($domain_name);

my $domain_zone; # Зона домена
my @domain_status; # Массив статусов домена

# Получаем whois домена
my $whois = `whois $domain_name` or die "Не удается запустить whois для домена $domain_name: $!";

if ($domain_name =~ /.* \. (.*)/x) { $domain_zone = $1; } # Определение зоны домена

if ($domain_zone eq "ru" || $domain_zone eq "su" || $domain_zone eq "рф" ) {
	get_whois_ru();
}
elsif ($domain_zone eq "com") {
	check_status_com();
	print "@domain_status";
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

# Функция определяет статусы международного домена
sub check_status_com {

	#if (/ .* Domain \s Status: \s (\w*) \s .* /x) { push (@domain_status, $1); }
	#@domain_status = grep{/ .* Domain \s Status: \s (\w*) \s .* /x} split / /, $whois_output;

	return @domain_status;
}

sub get_whois_ru {
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
	p %whois_variable;
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
