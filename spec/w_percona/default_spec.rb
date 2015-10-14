require_relative '../spec_helper'

describe 'w_percona::default' do

  context 'with default setting' do

    let(:web_apps) do
      [
        {vhost: {main_domain: 'example.com'}, connection_domain: { webapp_domain: 'webapp.example.com' }, mysql: [ { db: 'db1', user: 'user', password: 'pw' } ] },
        {vhost: {main_domain: 'ex.com'}, connection_domain: { webapp_domain: 'webapp.example.com' }, mysql: [ { db: 'db2', user: 'user', password: 'pw' } ] }
      ]
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['w_common']['web_apps'] = web_apps
        node.set['dbhosts']['webapp_ip'] = ['1.1.1.1', '2.2.2.2']
        node.set['w_percona']['xinetd_enabled'] = true
        node.automatic['hostname'] = 'dbhost.example.com'
        node.set['percona']['cluster']['cluster_ips'] = ['10.10.10.10', '10.10.10.11', '10.10.10.12']
        node.set['percona']['server']['role'] = ['cluster']
        node.set['percona']['cluster']['wsrep_sst_auth'] = 'ssttestuser:ssttestpassword'
      end.converge(described_recipe)
    end

    before do
      stub_data_bag_item('w_percona', 'db_credential').and_return('id' => 'db_credential', 'root_password' => 'rootpassword', 'backup_password' => 'backuppassword')
      stub_command("grep 9200/tcp /etc/services").and_return(false)
      stub_command("mysqladmin --user=root --password='' version").and_return(true)
      stub_command("mysql -uroot -p'rootpassword' -e \"SELECT user FROM mysql.user where host='localhost' and user='clustercheck';\" | grep -c \"clustercheck\"").and_return(false)
    end

    it 'enables firewall' do
      expect(chef_run).to install_firewall('default')
    end

    [3306, 4444, 4567, 4568, 9200].each do |percona_port|
      it "runs resoruce firewall_rule to open port #{percona_port}" do
        expect(chef_run).to create_firewall_rule("percona port #{percona_port.to_s}").with(port: percona_port, protocol: :tcp)
      end
    end

    %w( cluster backup toolkit ).each do |recipe|
      it "runs recipe percona::#{recipe}" do
        expect(chef_run).to include_recipe("percona::#{recipe}")
      end
    end

    it 'creats main config file' do
      expect(chef_run).to create_template('/etc/mysql/my.cnf').with(source: 'my.cnf.cluster.erb')
    end

    it 'creats /etc/mysql/my.cnf' do
      expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content('gcomm://10.10.10.10,10.10.10.11,10.10.10.12')
      expect(chef_run).to render_file('/etc/mysql/my.cnf').with_content('wsrep_sst_auth                 = ssttestuser:ssttestpassword')
    end

    it 'runs recipe w_percona::database' do
      expect(chef_run).to include_recipe('w_percona::database')
    end

    it 'not runs recipe w_percona::xinetd' do
      expect(chef_run).to include_recipe('w_percona::xinetd')
    end


  end
end