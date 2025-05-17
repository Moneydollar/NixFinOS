{ config, pkgs, inputs, username, ... }:

  let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
  in
{

  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
    profiles= {
      default = {
        id = 0;
        name = "default";
        isDefault = true; 

        # Hide tab bar because we have tree style tabs
        userChrome = '' 
       

       #unified-extensions-button{
          width: 3px;
          padding-inline: 0 !important
        }
        #unified-extensions-button > .toolbarbutton-icon {
            width: 0 !important;
        }
        }'';
        search = {
          force = true;
          default = "ddg";
          order = [
            "ddg"
            "google"
          ];
          };
    };
    default.extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
          bitwarden
          ublock-origin
          nighttab
          return-youtube-dislikes
          darkreader
          sponsorblock
          material-icons-for-github
          privacy-badger
          stylus
        ];
  };
    /* ---- POLICIES ---- */
    # Check about:policies#documentation for options.

    
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value= true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest =false;
      Locked = false;
       };
      DisablePocket = true;
      Preferences = { 
        "intl.accept_languages" = "en-US,en";

        "browser.startup.page" = 3; # Resume previous session on startup
        "browser.aboutConfig.showWarning" = lock-false; # I sometimes know what I'm doing
        "browser.ctrlTab.sortByRecentlyUsed" = lock-false; # (default) Who wants that?
        "browser.download.useDownloadDir" = lock-false; # Ask where to save stuff
        "privacy.clearOnShutdown.history" = lock-false; # We want to save history on exit
        "browser.shell.shortcutFavicons" = lock-false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts"	= lock-false;


        

        # Allow executing JS in the dev console
        "devtools.chrome.enabled" = lock-true;

        # Disable browser crash reporting
        "browser.tabs.crashReporting.sendReport" = lock-false;

        # Allow userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;

        # Why the fuck can my search window make bell sounds
        "accessibility.typeaheadfind.enablesound" = lock-false;

        # Privacy
        "privacy.donottrackheader.enabled" = lock-true;
        "privacy.trackingprotection.enabled" = lock-true;
        "privacy.trackingprotection.socialtracking.enabled" = lock-true;
        "privacy.userContext.enabled" = lock-true;
        "privacy.userContext.ui.enabled" = lock-true;

        "browser.send_pings" = lock-false; # Don't respect <a ping=...>

        # This allows Firefox devs to test stuff on a subset of users.
        # Not with me please...
        "app.normandy.enabled" = lock-false;
        "app.shield.optoutstudies.enabled" = lock-false;

        "beacon.enabled" = lock-false; # No bluetooth location BS in my web browser please
        "device.sensors.enabled" = lock-false; # This isn't a phone
        "geo.enabled" = lock-false; # Disable geolocation altogether

        # ESNI is deprecated; ECH is recommended
        "network.dns.echconfig.enabled" = lock-true;
 
        # Disable telemetry for privacy reasons
        "toolkit.telemetry.archive.enabled" = lock-false;
        "toolkit.telemetry.enabled" = lock-false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.unified" = lock-false;
        "extensions.webcompat-reporter.enabled" = lock-false;
        "datareporting.policy.dataSubmissionEnabled" = lock-false;
        "datareporting.healthreport.uploadEnabled" = lock-false;
        "browser.ping-centre.telemetry" = lock-false;
        "browser.urlbar.eventTelemetry.enabled" = lock-false; # (default)
        "identity.fxaccounts.telemetry.clientAssociationPing.enabled" = lock-false;
        "toolkit.telemetry.updatePing.enabled" = lock-false;
        "toolkit.telemetry.user_characteristics_ping.opt-out" = lock-true;

        # Disable some useless stuff
        "extensions.pocket.enabled" = lock-false; # disable pocket, save links, send tabs
        "extensions.abuseReport.enabled" = lock-false; # don't show 'report abuse' in extensions
        "extensions.formautofill.creditCards.enabled" = lock-false; # don't auto-fill credit card information
        "identity.fxaccounts.enabled" = lock-false; # disable Firefox login
        "identity.fxaccounts.toolbar.enabled" = lock-false;
        "identity.fxaccounts.pairing.enabled" = lock-false;
        "identity.fxaccounts.commands.enabled" = lock-false;
        "browser.contentblocking.report.lockwise.enabled" = lock-false; # don't use Firefox password manager
        "browser.uitour.enabled" = lock-false; # no tutorial please
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;

        # Don't predict network requests
        "network.predictor.enabled" = lock-false;
        "browser.urlbar.speculativeConnect.enabled" = lock-false;

        # Disable annoying web features
        "dom.battery.enabled" = lock-false; # you don't need to see my battery...
        "dom.private-attribution.submission.enabled" = lock-false; # No PPA for me pls
      };
      
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"
      FirefoxHome = {
        SponsoredTopSites = false;
        SponsoredPocket = false;
        Highlights = false;
        TopSites = false;
      };
        
      };
      
      
      
    };
  }



