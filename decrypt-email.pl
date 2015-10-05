#!/usr/bin/perl -w
use Mail::GnuPG;
use MIME::Parser;
#use Data::Dumper;

use strict;


sub stdin {
   my $stdin = '';

   while(<ARGV>){
   $stdin .= $_;
   }
   if ($stdin eq '') {
        die ("Error: stdin appears to have no content.");
   }
    return $stdin;
}

my $stdin = &stdin();

my $parser = MIME::Parser->new;
$parser->output_to_core(1);
my $tmpdir = '/tmp';
my $source;

$parser->output_under($tmpdir);

eval { $source = $parser->parse_data($stdin) };

#print Dumper($source);

my $gnupg = new Mail::GnuPG(passphrase => $ENV{'GPG_PASSPHRASE'});

if (not $gnupg->is_encrypted($source)){
  my $info=$source->head->get('from')." to ".$source->head->get('to').":".$source->head->get('subject');
  $info =~ s/[\r\n]+//g;
  warn($info."\n");
  die("is not encrypted\n");
}

my ($return,$keyid,$uid) = $gnupg->decrypt($source);
if ($return != 0){
#  print Dumper(@retval);
  die("could not decrypt\n");
}

my $decrypted=$gnupg->{decrypted};

#print Dumper($decrypted);

my $head=$source->head();
if ($decrypted->effective_type eq "multipart/mixed" || defined $decrypted->preamble){
  $head->replace('Content-Type','multipart/mixed; boundary="'.$head->multipart_boundary.'"');
  $decrypted->head($head);
  $decrypted->sync_headers(
          'Length'        =>  'COMPUTE',
          'Nonstandard'  =>  'ERASE'
  );
} else {
  $head->replace('Content-Transfer-Encoding', $decrypted->head()->mime_encoding);
  my $charset="";
  if ($source->mime_type eq "multipart/encrypted"){
    $charset=$decrypted->head()->mime_attr('content-type.charset');
  } else {
    $charset=$source->head()->mime_attr('content-type.charset');
  }
  $head->replace('Content-Type', $decrypted->mime_type()."; charset=".$charset);
  $decrypted->head($head);
}

if(length($decrypted->stringify_body())==0){
  die("body lenght is 0");
}
$decrypted->print(\*STDOUT);

$source->purge();
$decrypted->purge();

