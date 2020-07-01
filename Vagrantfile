# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'net/ssh'
require 'yaml'

required_plugins = %w(
  vagrant-hostmanager
)

def ip(n)
  "#{IP_PREFIX}.#{n}"
end

GB=1024

IP_PREFIX="172.22.22" # vbox virtual bridge
#IP_PREFIX="172.55.55" # libvirt virtual bridge

NODE_RAM=2048
MASTER_RAM=4096
DISK_SIZE=10*GB
ADD_DISK_FLAG=false

MACHINES= [
  { name: "control" , ip: ip(101), primary: true , cpus: 4, mem: 1024      , add_disk: false },
  { name: "facility", ip: ip(141), primary: false, cpus: 2, mem: 1024      , add_disk: false },
  { name: "master"  , ip: ip(122), primary: false, cpus: 4, mem: MASTER_RAM, add_disk: ADD_DISK_FLAG, size: DISK_SIZE },
  { name: "node1"   , ip: ip(131), primary: false, cpus: 4, mem: NODE_RAM  , add_disk: ADD_DISK_FLAG, size: DISK_SIZE },
  { name: "node2"   , ip: ip(132), primary: false, cpus: 4, mem: NODE_RAM  , add_disk: ADD_DISK_FLAG, size: DISK_SIZE },
  { name: "node3"   , ip: ip(133), primary: false, cpus: 4, mem: NODE_RAM  , add_disk: ADD_DISK_FLAG, size: DISK_SIZE },
]

ANSIBLE_VARS="ansible/inventory/vars.yml"


Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"

  # we want to run graphical tools from machines
  config.ssh.forward_x11 = true
  config.ssh.forward_agent = true

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

#  config.vm.synced_folder ".", "/vagrant",
#                          type: "nfs",
#                          linux__nfs_options: ['rw','no_subtree_check','root_squash','async']

  if Vagrant.has_plugin?("vagrant-cachier")
    #config.cache.scope = :box unless ENV['VAGRANT_CACHIER_BOX_CACHING'] == false
    config.cache.scope = :machine

    config.cache.synced_folder_opts = {
      type: :nfs,
      # The nolock option can be useful for an NFSv3 client that wants to avoid the
      # NLM sideband protocol. Without this option, apt-get might hang if it tries
      # to lock files needed for /var/cache/* operations. All of this can be avoided
      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
      #      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      mount_options: ['rw', 'vers=4', 'tcp', 'nolock']
    }
  end

  # vagrant-hostmanager: Configure /etc/hosts in machines so that they can look up each other
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  config.vm.provider :libvirt do |libvirt|
    # Avoid "Call to virDomainCreateWithFlags failed: unsupported configuration: host doesn't support invariant TSC" error when using snapshots
    libvirt.cpu_mode = 'host-passthrough'   
  end

  MACHINES.each do |m|
    node = m[:name]
    config.vm.define node, primary: m[:primary] do |c|
      c.vm.hostname = "#{node}.example.com"
      c.vm.network :private_network, :ip => m[:ip]
      c.hostmanager.aliases = [node]

      c.vm.provider :libvirt do |libvirt|
        libvirt.memory = m[:mem]
        libvirt.cpus = m[:cpus]
        libvirt.storage :file, :device => 'vdb', :size => '20G', :type => 'qcow2', :cache => 'writeback' if m[:add_disk]
      end

      c.vm.provider "virtualbox" do |vb|
        vb.cpus = m[:cpus]
        vb.memory = m[:mem]
        
        add_disk vb, c.vm.hostname, m[:size], 1, 0 if m[:add_disk]
        add_disk vb, c.vm.hostname, m[:size], 1, 1 if m[:add_disk]
      end

    end
  end

  config.vm.provision "shell", name: "link-vagrant", path: "lib/exec/link-vagrant"
  config.vm.provision "shell", name: "install-ansible", path: "lib/exec/install-ansible"
  config.vm.provision "shell", name: "set-ssh-key", path: "lib/exec/set-ssh-key"

end


def generate_host_vars
  map = Hash.new

  map["all"] = { "hosts" => {}}

  MACHINES.each do |m|
    map["all"]["hosts"][m[:name]] = { "node_ip" => m[:ip]}
  end

  File.open(ANSIBLE_VARS, "w") { |f| f.write(map.to_yaml) }
end

def install_plugins(plugins)
  needs_restart = false
  plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
      system "vagrant plugin install #{plugin}"
      needs_restart = true
    end
  end

  if needs_restart
    exec "vagrant #{ARGV.join' '}"
  end
end

def vagrant_dir()
  dir = Pathname.new(Dir.pwd)
  loop do
    return dir if (dir + 'Vagrantfile').exist?
    return nil if dir.root?
    dir = dir.parent
  end
end

def create_ssh_key()
  vagrant_dir = vagrant_dir()

  # Generate a ssh key for mutual machine login
  if vagrant_dir and not File.exist?("#{vagrant_dir}/.ssh/id_rsa")
    FileUtils.mkdir_p "#{vagrant_dir}/.ssh", :mode => 0700

    key = OpenSSL::PKey::RSA.new 2048
    type = key.public_key.ssh_type
    data = [ key.public_key.to_blob ].pack('m0')

    File.open("#{vagrant_dir}/.ssh/id_rsa", 'w', 0600) do |file|
      file.write key.to_pem
    end

    File.open("#{vagrant_dir}/.ssh/id_rsa.pub", 'w', 0600) do |file|
      file.puts "#{type} #{data} ansible"
    end
  end
end


install_plugins required_plugins
create_ssh_key

generate_host_vars

