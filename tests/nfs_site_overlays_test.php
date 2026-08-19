<?php

if ($argc !== 6) {
    fwrite(STDERR, "Usage: php nfs_site_overlays_test.php <plugin> <confirmation-url> <thankyou-page> <thankyou-url> <foreign-page>\n");
    exit(2);
}

define('PHPLISTINIT', true);

class phplistPlugin
{
    public function activate()
    {
    }
}

$pluginFile = $argv[1];
$expectedConfirmationUrl = $argv[2];
$thankyouPage = (int) $argv[3];
$expectedThankyouUrl = $argv[4];
$foreignPage = (int) $argv[5];

require $pluginFile;

$plugin = new NFSCustomizationsPlugin();
$confirmationMethod = new ReflectionMethod($plugin, 'confirmationRedirectUrl');

if ($confirmationMethod->getNumberOfRequiredParameters() !== 0) {
    fwrite(STDERR, "confirmationRedirectUrl() must not require a subscribe page ID\n");
    exit(1);
}

$actualConfirmationUrl = $plugin->confirmationRedirectUrl();
if ($actualConfirmationUrl !== $expectedConfirmationUrl) {
    fwrite(STDERR, sprintf(
        "Wrong confirmation URL: expected %s, got %s\n",
        $expectedConfirmationUrl,
        $actualConfirmationUrl
    ));
    exit(1);
}

$thankyouMarkup = $plugin->parseThankyou($thankyouPage, 0, 'unchanged');
if (strpos($thankyouMarkup, $expectedThankyouUrl) === false) {
    fwrite(STDERR, sprintf("Thank-you URL missing for page %d\n", $thankyouPage));
    exit(1);
}

$foreignMarkup = $plugin->parseThankyou($foreignPage, 0, 'unchanged');
if ($foreignMarkup !== 'unchanged') {
    fwrite(STDERR, sprintf("Foreign page %d unexpectedly has a redirect\n", $foreignPage));
    exit(1);
}

fwrite(STDOUT, "overlay behavior ok\n");
