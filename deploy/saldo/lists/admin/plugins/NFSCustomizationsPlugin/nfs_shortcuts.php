<?php

if (!defined('PHPLISTINIT')) {
    exit;
}

$links = array(
    array('details&pi=SubscribersPlugin', 'Search Subscribers'),
    array('history&pi=SubscribersPlugin', 'Subscription History'),
    array('reports&pi=SubscribersPlugin&report=subscriptions', 'Subscription Graph'),
    array('campaigns&pi=CampaignsPlugin', 'Manage Campaigns'),
    array('manage&pi=Autoresponder', 'Manage Autoresponders'),
    array('main&pi=MessageStatisticsPlugin', 'Campaign Statistics'),
    array('eventlog', 'Event Log'),
    array('spage', 'Subscribe Pages'),
    array('reconcileusers', 'Reconcile Subscribers'),
);

echo '<h3>NFS Shortcuts</h3>';
echo '<p class="information">Quick links for frequently used pages.</p>';
echo '<ul class="list-unstyled">';
foreach ($links as $entry) {
    $url = $entry[0];
    $label = $entry[1];
    // Never inherit current plugin context; use each shortcut URL as-is.
    $link = PageLink2($url, $label, '', true);
    if ($link) {
        echo '<li>'.$link.'</li>';
    }
}
echo '</ul>';
