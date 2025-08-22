function litmus
    switch $argv[1]
        case up
            if test (count $argv) -ge 2
                set provision_target $argv[2]
            else
                set provision_target "default"
            end

            echo "Running litmus up with target: $provision_target"
            pdk bundle exec rake "litmus:provision_list[$provision_target]"
            and pdk bundle exec rake 'litmus:install_agent'
            and pdk bundle exec rake 'litmus:install_module'

        case provision
            if test (count $argv) -ge 2
                set provision_target $argv[2]
            else
                set provision_target "default"
            end

            echo "Provisioning with target: $provision_target"
            pdk bundle exec rake "litmus:provision_list[$provision_target]"

        case agent
            if test (count $argv) -ge 2
                set agent_version $argv[2]
                echo "Installing puppet agent version: $agent_version"
                pdk bundle exec rake "litmus:install_agent[$agent_version]"
            else
                echo "Installing puppet agent (latest)"
                pdk bundle exec rake 'litmus:install_agent'
            end

        case module
            echo "Installing module"
            pdk bundle exec rake 'litmus:install_module'

        case down
            echo "Tearing down environment"
            pdk bundle exec rake "litmus:tear_down"

        case test
            echo "Running acceptance tests"
            pdk bundle exec rake 'litmus:acceptance:parallel'

        case retest
            echo "Reinstalling module and running acceptance tests"
            pdk bundle exec rake 'litmus:install_module'
            and pdk bundle exec rake 'litmus:acceptance:parallel'

        case attach
            if test (count $argv) -lt 2
                echo "Error: Please specify an image name"
                echo "Usage: litmus attach <image_name>"
                echo "Available platforms:"
                grep "platform:" spec/fixtures/litmus_inventory.yaml | sed 's/.*platform: /  /' | sort -u
                return 1
            end

            set image_name $argv[2]
            
            # Check if inventory file exists
            if not test -f spec/fixtures/litmus_inventory.yaml
                echo "Error: litmus_inventory.yaml not found"
                return 1
            end

            # Parse the inventory file to find the container ID for the given image
            set container_id (ruby -ryaml -e "
                inventory = YAML.load_file('spec/fixtures/litmus_inventory.yaml')
                image = '$image_name'
                
                # Search through all targets in all groups
                inventory['groups'].each do |group|
                    group['targets'].each do |target|
                        if target['facts'] && target['facts']['platform']
                            # Match the platform against the provided image name
                            platform = target['facts']['platform']
                            # Remove 'litmusimage/' prefix for comparison
                            platform_clean = platform.gsub('litmusimage/', '')
                            
                            if platform_clean == image || platform == image
                                puts target['facts']['container_id']
                                exit
                            end
                        end
                    end
                end
            " 2>/dev/null)

            if test -z "$container_id"
                echo "Error: Could not find container for image '$image_name' in inventory"
                echo "Available platforms:"
                grep "platform:" spec/fixtures/litmus_inventory.yaml | sed 's/.*platform: /  /' | sort -u
                return 1
            end

            echo "Attaching to container: $container_id (image: $image_name)"
            docker exec -it $container_id bash

        case '*'
            echo "Usage: litmus [command] [options]"
            echo ""
            echo "Setup commands:"
            echo "  litmus up [target]       - Provision, install agent and module (default: 'default')"
            echo "  litmus provision [target]- Provision nodes only (default: 'default')"
            echo "  litmus agent [version]   - Install puppet agent (optional version)"
            echo "  litmus module            - Install the module"
            echo ""
            echo "Test commands:"
            echo "  litmus test              - Run acceptance tests in parallel"
            echo "  litmus retest            - Reinstall module and run acceptance tests"
            echo ""
            echo "Utility commands:"
            echo "  litmus attach <image>    - Attach to a running container"
            echo "  litmus down              - Tear down the environment"
    end
end
