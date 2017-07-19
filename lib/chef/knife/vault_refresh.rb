# Description: Chef-Vault VaultReapply class
# Copyright 2013-15, Nordstrom, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "chef/knife/vault_base"

class Chef
  class Knife
    class VaultRefresh < Knife
      include Chef::Knife::VaultBase

      banner "knife vault refresh VAULT ITEM"

      option :clean_unknown_clients,
        :long => "--clean-unknown-clients",
        :description => "Remove unknown clients during refresh"

      option :force_reencryption,
        :long => "--force-reencryption",
        :description => "Force reencrypt symetrical key for all clients/admins"

      def run
        vault = @name_args[0]
        item = @name_args[1]
        clean = config[:clean_unknown_clients]
        force_reencryption = config[:force_reencryption]

        set_mode(config[:vault_mode])

        if vault && item
          begin
            vault_item = ChefVault::Item.load(vault, item)
            vault_item.force_reencryption = force_reencryption
            vault_item.refresh(clean)
          rescue ChefVault::Exceptions::KeysNotFound,
                 ChefVault::Exceptions::ItemNotFound

            raise ChefVault::Exceptions::ItemNotFound,
                  "#{vault}/#{item} does not exist, "\
                  "use 'knife vault create' to create."
          end
        else
          show_usage
        end
      end
    end
  end
end
