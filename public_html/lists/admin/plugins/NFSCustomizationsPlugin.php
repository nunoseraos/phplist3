<?php

if (!defined('PHPLISTINIT')) {
    exit;
}

class NFSCustomizationsPlugin extends phplistPlugin
{
    public $name = 'NFS Customizations';
    public $version = '0.2.1';
    public $authors = 'NFS';
    public $description = 'Reusable customizations for NFS phpList upgrades.';
    public $coderoot = 'plugins/NFSCustomizationsPlugin/';
    public $topMenuLinks = array(
        'nfs_shortcuts' => array('category' => 'subscribers'),
    );
    public $pageTitles = array(
        'nfs_shortcuts' => 'NFS Shortcuts',
    );

    private $defaultThankyouRedirects = array(
        5  => 'https://segurosmais.pt/resultado/automovel/',
        6  => 'https://segurosmais.pt/resultado/saude/',
        7  => 'https://segurosmais.pt/resultado/dentario/',
        8  => 'https://segurosmais.pt/resultado/vida/',
        9  => 'https://segurosmais.pt/resultado/bem-vindo/',
        10 => 'https://segurosmais.pt/resultado/casa/',
        11 => 'https://segurosmais.pt/resultado/protecao-ao-credito/',
        12 => 'https://segurosmais.pt/resultado/credito-pessoal/',
        13 => 'https://segurosmais.pt/resultado/credito-consolidado/',
        18 => 'https://creditoacertado.pt/resultado/credito-pessoal/',
    );

    private $thankyouRedirectsByProfile = array(
        'segurosmais' => array(
            5  => 'https://segurosmais.pt/resultado/automovel/',
            6  => 'https://segurosmais.pt/resultado/saude/',
            7  => 'https://segurosmais.pt/resultado/dentario/',
            8  => 'https://segurosmais.pt/resultado/vida/',
            9  => 'https://segurosmais.pt/resultado/bem-vindo/',
            10 => 'https://segurosmais.pt/resultado/casa/',
            11 => 'https://segurosmais.pt/resultado/protecao-ao-credito/',
            12 => 'https://segurosmais.pt/resultado/credito-pessoal/',
            13 => 'https://segurosmais.pt/resultado/credito-consolidado/',
            18 => 'https://creditoacertado.pt/resultado/credito-pessoal/',
        ),
        'credito_saldo' => array(
            14 => 'https://creditosim.pt/resultado/credito-pessoal/',
            18 => 'https://creditoacertado.pt/resultado/credito-pessoal/',
        ),
    );

    private $defaultConfirmationRedirects = array(
        1  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        5  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        6  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        7  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        8  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        9  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        10 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        11 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        12 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        13 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        14 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        18 => 'https://creditoacertado.pt/welcome-simulacoes/',
        999 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
    );

    private $confirmationRedirectsByProfile = array(
        'segurosmais' => array(
            1  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            5  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            6  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            7  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            8  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            9  => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            10 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            11 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            12 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            13 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            14 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
            18 => 'https://creditoacertado.pt/welcome-simulacoes/',
            999 => 'https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/',
        ),
        'credito_saldo' => array(
            14 => 'https://saldo.pt/pagina-subscricao-newsletter-simulacoes/',
            18 => 'https://creditoacertado.pt/welcome-simulacoes/',
        ),
    );

    private $defaultSuppressPostConfirmMailPages = array(
        1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 18,
    );

    public function activate()
    {
        parent::activate();

        // Ensure the shortcuts entry is visible in Subscribers even when plugin top menu links
        // are not injected (for example, when not running as superuser).
        if (!isset($GLOBALS['pagecategories']['subscribers']['menulinks'])
            || !is_array($GLOBALS['pagecategories']['subscribers']['menulinks'])) {
            return;
        }

        $menuEntry = 'nfs_shortcuts&pi=NFSCustomizationsPlugin';
        if (!in_array($menuEntry, $GLOBALS['pagecategories']['subscribers']['menulinks'], true)) {
            array_unshift($GLOBALS['pagecategories']['subscribers']['menulinks'], $menuEntry);
        }
    }

    public function processQueueStart()
    {
        $this->autoSuppressHardFailuresFromEventLog();
        $this->monitorQueueHealthAndNotify();
    }

    public function validateSubscriptionPage($pageData)
    {
        if (!$this->isPostalValidationEnabled()) {
            return '';
        }
        if (empty($_POST['subscribe'])) {
            return '';
        }
        if (!isset($_POST['attribute9'])) {
            return '';
        }

        $postalCode = trim((string) $_POST['attribute9']);
        if ($postalCode === '') {
            return '';
        }

        if (!preg_match('/^[0-9]{4}-[0-9]{3}$/', $postalCode)) {
            return 'Invalid postal code. Use NNNN-NNN.';
        }

        return '';
    }

    public function parseThankyou($pageid = 0, $userid = 0, $text = '')
    {
        $redirectUrl = $this->thankyouRedirectUrl((int) $pageid);
        if ($redirectUrl === '') {
            return $text;
        }

        return $this->buildRedirectMarkup($redirectUrl);
    }

    public function subscriberConfirmation($subscribepageID, $userdata = array())
    {
        $email = '';
        if (is_array($userdata) && !empty($userdata['email'])) {
            $email = trim((string) $userdata['email']);
        }
        if ($email === '') {
            return;
        }
        if (!$this->shouldSuppressPostConfirmMail((int) $subscribepageID)) {
            return;
        }
        if (empty($_SESSION['subscriberConfirmed']) || !is_array($_SESSION['subscriberConfirmed'])) {
            $_SESSION['subscriberConfirmed'] = array();
        }

        // Core checks this flag before sending confirmationsubject/confirmationmessage.
        $_SESSION['subscriberConfirmed'][$email] = time();
    }

    public function hidePostConfirmationMessageFields($subscribepageID)
    {
        return $this->shouldSuppressPostConfirmMail((int) $subscribepageID);
    }

    public function confirmationRedirectUrl($subscribepageID)
    {
        return $this->redirectUrlForPage(
            $subscribepageID,
            'NFS_CONFIRMATION_REDIRECTS',
            $this->defaultConfirmationRedirects,
            $this->confirmationRedirectsByProfile
        );
    }

    public function parseOutgoingTextMessage($messageid, $content, $destination, $userdata = null)
    {
        if (!$this->isSignatureRemovalEnabled()) {
            return $content;
        }

        $content = str_replace("\n\n-- powered by phpList, www.phplist.com --\n\n", "\n", $content);
        $content = str_ireplace('powered by phpList, www.phplist.com', '', $content);

        return $content;
    }

    public function parseOutgoingHTMLMessage($messageid, $content, $destination, $userdata = null)
    {
        if (!$this->isSignatureRemovalEnabled()) {
            return $content;
        }

        $content = preg_replace('#<p[^>]*class=["\']poweredby["\'][^>]*>.*?</p>#is', '', $content);
        $content = preg_replace('#<div[^>]*>\s*powered by\s*<a[^>]*>phpList</a>\s*</div>#is', '', $content);
        $content = str_ireplace('powered by phpList, www.phplist.com', '', $content);

        return $content;
    }

    private function isPostalValidationEnabled()
    {
        if (!defined('NFS_VALIDATE_ATTRIBUTE9')) {
            return true;
        }

        return (bool) constant('NFS_VALIDATE_ATTRIBUTE9');
    }

    private function isSignatureRemovalEnabled()
    {
        if (!defined('NFS_REMOVE_PHPLIST_SIGNATURE')) {
            return true;
        }

        return (bool) constant('NFS_REMOVE_PHPLIST_SIGNATURE');
    }

    private function isAutoHardFailSuppressionEnabled()
    {
        if (!defined('NFS_AUTO_SUPPRESS_HARD_FAILS')) {
            return true;
        }

        return (bool) constant('NFS_AUTO_SUPPRESS_HARD_FAILS');
    }

    private function isQueueAlertEnabled()
    {
        if (!defined('NFS_QUEUE_ALERTS_ENABLED')) {
            return true;
        }

        return (bool) constant('NFS_QUEUE_ALERTS_ENABLED');
    }

    private function queueAlertEmailAddress()
    {
        if (defined('NFS_QUEUE_ALERT_EMAIL')) {
            $configured = trim((string) constant('NFS_QUEUE_ALERT_EMAIL'));
            if ($configured !== '') {
                return $configured;
            }
        }

        return 'nuno.seraos@gmail.com';
    }

    private function queueAlertStuckHours()
    {
        $hours = defined('NFS_QUEUE_STUCK_HOURS')
            ? (int) constant('NFS_QUEUE_STUCK_HOURS')
            : 6;

        return $hours > 0 ? $hours : 6;
    }

    private function queueAlertCooldownMinutes()
    {
        $minutes = defined('NFS_QUEUE_ALERT_COOLDOWN_MINUTES')
            ? (int) constant('NFS_QUEUE_ALERT_COOLDOWN_MINUTES')
            : 360;

        return $minutes > 0 ? $minutes : 360;
    }

    private function autoHardFailThreshold()
    {
        $threshold = defined('NFS_AUTO_SUPPRESS_THRESHOLD')
            ? (int) constant('NFS_AUTO_SUPPRESS_THRESHOLD')
            : 2;

        return $threshold > 0 ? $threshold : 1;
    }

    private function autoHardFailWindowHours()
    {
        $hours = defined('NFS_AUTO_SUPPRESS_WINDOW_HOURS')
            ? (int) constant('NFS_AUTO_SUPPRESS_WINDOW_HOURS')
            : 168;

        return $hours > 0 ? $hours : 24;
    }

    private function autoHardFailMaxScan()
    {
        $maxScan = defined('NFS_AUTO_SUPPRESS_MAX_SCAN')
            ? (int) constant('NFS_AUTO_SUPPRESS_MAX_SCAN')
            : 2000;

        return $maxScan > 0 ? $maxScan : 500;
    }

    private function autoSuppressHardFailuresFromEventLog()
    {
        if (!$this->isAutoHardFailSuppressionEnabled()) {
            return;
        }
        if (empty($GLOBALS['tables']['eventlog'])
            || empty($GLOBALS['tables']['user'])
            || empty($GLOBALS['tables']['user_blacklist'])
            || empty($GLOBALS['tables']['user_blacklist_data'])) {
            return;
        }

        $hours = $this->autoHardFailWindowHours();
        $threshold = $this->autoHardFailThreshold();
        $maxScan = $this->autoHardFailMaxScan();
        $counts = array();

        $query = Sql_Query(sprintf(
            'select entry from %s
            where entered >= date_sub(now(), interval %d hour)
              and entry like "Error sending email to %% SMTP Error:%%"
              and entry like "%%The mail server could not deliver mail to%%"
            order by id desc
            limit %d',
            $GLOBALS['tables']['eventlog'],
            $hours,
            $maxScan
        ));

        while ($row = Sql_Fetch_Array($query)) {
            if (empty($row['entry'])) {
                continue;
            }
            $email = $this->extractHardFailRecipient($row['entry']);
            if ($email === '') {
                continue;
            }

            if (!isset($counts[$email])) {
                $counts[$email] = 0;
            }
            ++$counts[$email];
        }

        foreach ($counts as $email => $count) {
            if ($count < $threshold) {
                continue;
            }
            $this->blacklistHardFailRecipient($email, $count, $hours);
        }
    }

    private function monitorQueueHealthAndNotify()
    {
        if (!$this->isQueueAlertEnabled()) {
            return;
        }
        if (empty($GLOBALS['tables']['message']) || empty($GLOBALS['tables']['autoresponders'])) {
            return;
        }

        $issues = array();

        $suspendedAr = Sql_Query(sprintf(
            'select ar.id as autoresponder_id, ar.description as autoresponder_description,
                    m.id as message_id, m.subject, m.status, m.sendstart, m.sent
             from %s ar
             join %s m on m.id = ar.mid
             where ar.enabled = 1 and m.status = "suspended"
             order by ar.id',
            $GLOBALS['tables']['autoresponders'],
            $GLOBALS['tables']['message']
        ));
        while ($row = Sql_Fetch_Array($suspendedAr)) {
            $issues[] = array(
                'type' => 'autoresponder_suspended',
                'ar_id' => (int) $row['autoresponder_id'],
                'ar_description' => (string) $row['autoresponder_description'],
                'message_id' => (int) $row['message_id'],
                'subject' => (string) $row['subject'],
                'status' => (string) $row['status'],
                'sendstart' => (string) $row['sendstart'],
                'sent' => (string) $row['sent'],
            );
        }

        $stuckHours = $this->queueAlertStuckHours();
        $stuckInprocess = Sql_Query(sprintf(
            'select id as message_id, subject, status, sendstart, sent
             from %s
             where status = "inprocess"
               and sendstart is not null
               and sendstart < date_sub(now(), interval %d hour)
             order by sendstart asc
             limit 50',
            $GLOBALS['tables']['message'],
            $stuckHours
        ));
        while ($row = Sql_Fetch_Array($stuckInprocess)) {
            $issues[] = array(
                'type' => 'campaign_stuck_inprocess',
                'message_id' => (int) $row['message_id'],
                'subject' => (string) $row['subject'],
                'status' => (string) $row['status'],
                'sendstart' => (string) $row['sendstart'],
                'sent' => (string) $row['sent'],
            );
        }

        if (count($issues) === 0) {
            return;
        }

        $hash = sha1(json_encode($issues));
        $lastHash = (string) $this->getConfig('queue_alert_hash');
        $lastSent = (int) $this->getConfig('queue_alert_sent_ts');
        $cooldownSeconds = $this->queueAlertCooldownMinutes() * 60;
        if ($lastHash === $hash && $lastSent > 0 && (time() - $lastSent) < $cooldownSeconds) {
            return;
        }

        $to = trim($this->queueAlertEmailAddress());
        if (!filter_var($to, FILTER_VALIDATE_EMAIL)) {
            return;
        }

        $activeUrl = 'https://' . getConfig('website') . '/lists/admin/?page=messages&tab=active';
        $subject = sprintf('[phpList] Queue alert: %d issue(s)', count($issues));
        $lines = array();
        $lines[] = 'NFS queue monitor detected issues.';
        $lines[] = 'Check: ' . $activeUrl;
        $lines[] = '';
        foreach ($issues as $issue) {
            if ($issue['type'] === 'autoresponder_suspended') {
                $lines[] = sprintf(
                    '[AR suspended] AR #%d "%s" -> message #%d "%s" status=%s sent=%s sendstart=%s',
                    $issue['ar_id'],
                    $issue['ar_description'],
                    $issue['message_id'],
                    $issue['subject'],
                    $issue['status'],
                    $issue['sent'],
                    $issue['sendstart']
                );
            } else {
                $lines[] = sprintf(
                    '[Stuck inprocess] message #%d "%s" status=%s sent=%s sendstart=%s',
                    $issue['message_id'],
                    $issue['subject'],
                    $issue['status'],
                    $issue['sent'],
                    $issue['sendstart']
                );
            }
        }
        $body = implode("\n", $lines);

        $sent = sendMail($to, $subject, $body);
        if ($sent) {
            $this->writeConfig('queue_alert_hash', $hash);
            $this->writeConfig('queue_alert_sent_ts', (string) time());
        }
    }

    private function extractHardFailRecipient($entry)
    {
        if (!is_string($entry)) {
            return '';
        }
        if (!preg_match('/^Error sending email to\\s+([A-Z0-9._%+\\-]+@[A-Z0-9.\\-]+\\.[A-Z]{2,})\\s+SMTP Error:/i', $entry, $matches)) {
            return '';
        }

        $email = strtolower(trim($matches[1]));
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return '';
        }

        return $email;
    }

    private function isAlreadyBlacklisted($email)
    {
        $exists = Sql_Fetch_Row_Query(sprintf(
            'select count(*) from %s where email = "%s"',
            $GLOBALS['tables']['user_blacklist'],
            sql_escape($email)
        ));

        return !empty($exists[0]);
    }

    private function blacklistHardFailRecipient($email, $count, $hours)
    {
        if ($this->isAlreadyBlacklisted($email)) {
            return;
        }

        $safeEmail = sql_escape($email);
        $reason = sprintf(
            'NFS auto-blacklisted after %d SMTP hard failures in %d hours',
            (int) $count,
            (int) $hours
        );

        Sql_Query(sprintf(
            'insert ignore into %s (email,added) values ("%s",now())',
            $GLOBALS['tables']['user_blacklist'],
            $safeEmail
        ));

        Sql_Query(sprintf(
            'replace into %s (email,name,data) values ("%s","reason","%s")',
            $GLOBALS['tables']['user_blacklist_data'],
            $safeEmail,
            sql_escape($reason)
        ));

        Sql_Query(sprintf(
            'update %s set blacklisted = 1, confirmed = 0 where email = "%s"',
            $GLOBALS['tables']['user'],
            $safeEmail
        ));

        if (!empty($GLOBALS['tables']['eventlog'])) {
            Sql_Query(sprintf(
                'insert into %s (entered,page,entry) values(now(),"processqueue","%s")',
                $GLOBALS['tables']['eventlog'],
                sql_escape(sprintf('NFS auto-blacklisted %s due to repeated SMTP hard failures', $email))
            ));
        }
    }

    private function thankyouRedirectUrl($pageid)
    {
        return $this->redirectUrlForPage(
            $pageid,
            'NFS_THANKYOU_REDIRECTS',
            $this->defaultThankyouRedirects,
            $this->thankyouRedirectsByProfile
        );
    }

    private function redirectUrlForPage($pageid, $overrideConstant, $defaultRedirects, $profileRedirects)
    {
        $pageid = (int) $pageid;
        $redirects = $this->redirectsForCurrentProfile($defaultRedirects, $profileRedirects);
        if (defined($overrideConstant)) {
            $configuredRedirects = constant($overrideConstant);
            if (is_array($configuredRedirects)) {
                $redirects = $configuredRedirects;
            }
        }

        if (!isset($redirects[$pageid]) || !is_string($redirects[$pageid])) {
            return '';
        }

        $url = trim((string) $redirects[$pageid]);
        if ($url === '') {
            return '';
        }

        return $url;
    }

    private function redirectsForCurrentProfile($defaultRedirects, $profileRedirects)
    {
        $profile = $this->siteProfile();
        if (isset($profileRedirects[$profile]) && is_array($profileRedirects[$profile])) {
            return $profileRedirects[$profile];
        }

        return $defaultRedirects;
    }

    private function siteProfile()
    {
        $profile = defined('NFS_SITE_PROFILE')
            ? strtolower(trim((string) constant('NFS_SITE_PROFILE')))
            : $this->detectSiteProfile();

        $aliases = array(
            'credito' => 'credito_saldo',
            'creditosim' => 'credito_saldo',
            'saldo' => 'credito_saldo',
            'seguros' => 'segurosmais',
            'escolhas' => 'segurosmais',
        );

        if (isset($aliases[$profile])) {
            return $aliases[$profile];
        }

        return $profile !== '' ? $profile : 'segurosmais';
    }

    private function detectSiteProfile()
    {
        $signals = array();
        if (defined('PHPMAILERHOST')) {
            $signals[] = strtolower((string) constant('PHPMAILERHOST'));
        }
        if (defined('ACCESS_CONTROL_ALLOW_ORIGINS') && is_array(constant('ACCESS_CONTROL_ALLOW_ORIGINS'))) {
            foreach (constant('ACCESS_CONTROL_ALLOW_ORIGINS') as $origin) {
                $signals[] = strtolower((string) $origin);
            }
        }
        if (function_exists('getConfig')) {
            $signals[] = strtolower((string) getConfig('website'));
        }

        $combined = implode(' ', $signals);
        if (strpos($combined, 'simulacaocreditopessoal.com') !== false
            || strpos($combined, 'creditosim.pt') !== false
            || strpos($combined, 'saldo.pt') !== false) {
            return 'credito_saldo';
        }

        return 'segurosmais';
    }

    private function shouldSuppressPostConfirmMail($pageid)
    {
        $enabled = true;
        if (defined('NFS_SUPPRESS_POST_CONFIRMATION_EMAIL')) {
            $enabled = (bool) constant('NFS_SUPPRESS_POST_CONFIRMATION_EMAIL');
        }
        if (!$enabled) {
            return false;
        }

        $pageIds = $this->defaultSuppressPostConfirmMailPages;
        if (defined('NFS_SUPPRESS_POST_CONFIRMATION_EMAIL_PAGES')) {
            $configured = constant('NFS_SUPPRESS_POST_CONFIRMATION_EMAIL_PAGES');
            if (is_array($configured)) {
                $pageIds = array_map('intval', $configured);
            }
        }

        return in_array((int) $pageid, $pageIds, true);
    }

    private function buildRedirectMarkup($url)
    {
        $safeUrl = htmlspecialchars($url, ENT_QUOTES, 'UTF-8');

        return
            '<script>window.location.href=\''.$safeUrl.'\';</script>'.
            '<noscript><meta http-equiv="refresh" content="0;url='.$safeUrl.'" /></noscript>'.
            '<p><a href="'.$safeUrl.'">Continue</a></p>';
    }
}
