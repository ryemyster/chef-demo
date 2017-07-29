require 'serverspec'

# Required by serverspec
set :backend, :exec

pkg_list =
  if os[:family] == 'redhat'
    %w(curl bind-utils lsof)
  elsif ['debian', 'ubuntu'].include?(os[:family])
    %w(curl inetutils-traceroute)
  end

pkg_list.each do |pkgs|
  describe package pkgs do
    it { should be_installed }
  end
end

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match 'PasswordAuthentication no' }
end

describe command('date +%Z') do
  its(:stdout) { should match 'UTC' }
end

javahome_location =
  if os[:family] == 'redhat'
    '/usr/lib/jvm/java/release'
  elsif ['debian', 'ubuntu'].include?(os[:family])
    '/usr/lib/jvm/java-8-oracle-amd64/release'
  end

describe file javahome_location do
  its(:content) { should match 'JAVA_VERSION="1.8.0_101"' }
end

# variable for platform specific dependency package names
pkg_dep =
  if os[:family] == 'redhat'
    %w(SDL kernel-devel kernel-headers dkms git PyYAML.x86_64)
  elsif ['debian', 'ubuntu'].include?(os[:family])
    %w(build-essential dkms git python-yaml)
  end

# check that each dependency package is installed
pkg_dep.each do |pkg_deps|
  describe package pkg_deps do
    it { should be_installed }
  end
end

describe file('/opt/maven/apache-maven-3.3.9') do
  it { should be_directory }
  it { should be_owned_by 'deploy' }
end

describe file('/opt/jdk/jdk1.8.0_112') do
  it { should be_directory }
  it { should be_owned_by 'deploy' }
end

describe file('/usr/share/jenkins-cli.jar') do
  it { should be_owned_by 'root' }
end

# variable for platform specific systemd service locations
systemd_location =
  if os[:family] == 'redhat'
    '/usr/lib/systemd/system/ope.service'
  elsif ['debian', 'ubuntu'].include?(os[:family])
    '/etc/systemd/system/ope.service'
  end


describe file('/opt/deploy/.vagrant.d/Vagrantfile') do
  it { should be_owned_by 'deploy' }
  its(:content) { should match 'Give VM 1/5' }
  its(:content) { should match 'vbox.cpus = 1' }
end

describe command('chef -v') do
  its(:stdout) { should match 'Chef Development Kit Version: 0.11.2' }
end
