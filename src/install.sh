#!/bin/bash

echo "Installing 'drs' command aliases"
# Remove commands (do not delete entires from here to always get a clean state)
git config --unset alias.drs-get
git config --unset alias.drs-put
git config --unset alias.drs-update
git config --unset alias.drs-select
git config --unset alias.drs-create
git config --unset alias.drs-help
git config --unset alias.drs-info
git config --unset alias.drs-name

# Install commands (don't forget to update config-example)
echo "Adding drs-get"
git config --add alias.drs-get "!f() { ( \$DRS_HOME/get.sh \$@ ); }; f"
echo "Adding drs-put"
git config --add alias.drs-put "!f() { ( \$DRS_HOME/put.sh \$@ ); }; f"
echo "Adding drs-select"
git config --add alias.drs-select "!f() { ( \$DRS_HOME/select.sh \$@ ); }; f"
echo "Adding drs-create"
git config --add alias.drs-create "!f() { ( \$DRS_HOME/create.sh \$@ ); }; f"
echo "Adding drs-update"
git config --add alias.drs-update "!f() { ( \$DRS_HOME/update.sh \$@ ); }; f"
echo "Adding drs-info"
git config --add alias.drs-info "!f() { ( \$DRS_HOME/info.sh \$@ ); }; f"
echo "Adding drs-name"
git config --add alias.drs-name "!f() { ( \$DRS_HOME/name.sh \$@ ); }; f"
