{ __findFile, ... }:
{
  den.aspects.sentinel = {
    nixos =
      { pkgs, lib, ... }:
      {
        systemd.services.home-assistant = {
          after = [ "srv.mount" ];
          requires = [ "srv.mount" ];
        };

        services.home-assistant = {
          enable = true;
          openFirewall = true;
          config = {
            default_config = { };
            frontend.extra_module_url = [ "/local/community/lovelace-mushroom/mushroom.js" ];
            frontend.themes = "!include_dir_merge_named themes";
            homeassistant = {
              name = "Home";
              unit_system = "us_customary";
              time_zone = "America/Denver";
            };
            http = {
              server_host = "0.0.0.0";
              use_x_forwarded_for = true;
              trusted_proxies = [
                "127.0.0.1"
                "10.0.45.2/32"
                "10.0.40.6/32"
              ];
              ip_ban_enabled = true;
              login_attempts_threshold = 5;
            };
          };

          lovelaceConfig = {
            title = "Home";
            views = [
              {
                title = "Overview";
                path = "overview";
                type = "sections";
                max_columns = 1;
                sections = [
                  {
                    type = "grid";
                    title = "Security";
                    cards = [
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "lock.front_door_lock";
                        name = "Front Door";
                        icon = "mdi:lock";
                        tap_action = {
                          action = "toggle";
                        };
                        grid_options = {
                          columns = 12;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.front_door_opening";
                        name = "Front Door";
                        icon = "mdi:door";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.back_door_opening";
                        name = "Back Door";
                        icon = "mdi:door";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.garage_door_opening";
                        name = "Garage";
                        icon = "mdi:garage";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.kitchen_door_opening";
                        name = "Kitchen Door";
                        icon = "mdi:door";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                    ];
                  }
                  {
                    type = "grid";
                    title = "Who's Home";
                    cards = [
                      {
                        type = "custom:mushroom-person-card";
                        entity = "person.buttars";
                        name = "Buttars";
                      }
                      {
                        type = "custom:mushroom-person-card";
                        entity = "person.connor";
                        name = "Connor";
                      }
                    ];
                  }
                  {
                    type = "grid";
                    title = "Weather";
                    cards = [
                      {
                        type = "weather-forecast";
                        entity = "weather.forecast_home";
                        forecast_type = "daily";
                        show_current = true;
                        show_forecast = true;
                      }
                    ];
                  }
                ];
              }
              {
                title = "Overview (Desktop)";
                path = "overview-desktop";
                type = "sections";
                max_columns = 3;
                sections = [
                  {
                    type = "grid";
                    title = "Security";
                    column_span = 1;
                    cards = [
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "lock.front_door_lock";
                        name = "Front Door";
                        icon = "mdi:lock";
                        tap_action = {
                          action = "toggle";
                        };
                        grid_options = {
                          columns = 12;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.front_door_opening";
                        name = "Front Door";
                        icon = "mdi:door";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.back_door_opening";
                        name = "Back Door";
                        icon = "mdi:door";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.garage_door_opening";
                        name = "Garage";
                        icon = "mdi:garage";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                      {
                        type = "custom:mushroom-entity-card";
                        entity = "binary_sensor.kitchen_door_opening";
                        name = "Kitchen Door";
                        icon = "mdi:door";
                        grid_options = {
                          columns = 6;
                          rows = 1;
                        };
                      }
                    ];
                  }
                  {
                    type = "grid";
                    title = "Who's Home";
                    column_span = 1;
                    cards = [
                      {
                        type = "custom:mushroom-person-card";
                        entity = "person.buttars";
                        name = "Buttars";
                      }
                      {
                        type = "custom:mushroom-person-card";
                        entity = "person.connor";
                        name = "Connor";
                      }
                    ];
                  }
                  {
                    type = "grid";
                    title = "Weather";
                    column_span = 1;
                    cards = [
                      {
                        type = "weather-forecast";
                        entity = "weather.forecast_home";
                        forecast_type = "daily";
                        show_current = true;
                        show_forecast = true;
                      }
                    ];
                  }
                  {
                    type = "grid";
                    title = "Lock History";
                    column_span = 3;
                    cards = [
                      {
                        type = "logbook";
                        entities = [ "lock.front_door_lock" ];
                        hours_to_show = 48;
                        title = "Front Door Activity";
                      }
                    ];
                  }
                ];
              }
            ];
          };

          customComponents =
            let
              hacs-frontend = pkgs.home-assistant.python.pkgs.buildPythonPackage {
                pname = "hacs-frontend";
                version = "20250128065759";
                format = "wheel";
                src = pkgs.fetchurl {
                  url = "https://files.pythonhosted.org/packages/py3/h/hacs_frontend/hacs_frontend-20250128065759-py3-none-any.whl";
                  hash = "sha256-5rGWFx+8s8s+ztLEjnifPclGtZ90kEh98W2NTkeoX8Q=";
                };
              };
            in
            [
              (pkgs.buildHomeAssistantComponent {
                owner = "hacs";
                domain = "hacs";
                version = "2.0.5";
                src = pkgs.fetchFromGitHub {
                  owner = "hacs";
                  repo = "integration";
                  rev = "2.0.5";
                  hash = "sha256-xj+H75A6iwyGzMvYUjx61aGiH5DK/qYLC6clZ4cGDac=";
                };
                propagatedBuildInputs = with pkgs.home-assistant.python.pkgs; [ aiogithubapi ];
                postInstall = ''
                  ln -s ${hacs-frontend}/${pkgs.home-assistant.python.sitePackages}/hacs_frontend \
                    $out/custom_components/hacs/hacs_frontend
                  ${pkgs.jq}/bin/jq '.version = "2.0.5"' \
                    $out/custom_components/hacs/manifest.json > /tmp/manifest.json
                  mv /tmp/manifest.json $out/custom_components/hacs/manifest.json
                '';
              })
            ];

          extraComponents = [
            "analytics"
            "google_translate"
            "met"
            "radio_browser"
            "shopping_list"
            # Recommended for fast zlib compression
            # https://www.home-assistant.io/integrations/isal
            "isal"
            "mobile_app"
            "zha"
          ];
        };
      };
  };
}
