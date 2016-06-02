require 'spec_helper_acceptance'

describe 'rabbitmq' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include yum
        include stdlib
        include stdlib::stages
        include profile::package_management

        class { 'cegekarepos' : stage => 'setup_repo' }

        Yum::Repo <| title == 'cegeka-custom' |>
        Yum::Repo <| title == 'cegeka-custom-noarch' |>
        Yum::Repo <| title == 'cegeka-unsigned' |>
        Yum::Repo <| title == 'epel' |>

        class { 'rabbitmq::server':
          port              => '5673',
          delete_guest_user => true,
        }

        class { 'rabbitmq::config::definitions':
          rabbitmq_exchange => 'spectest_exchange',
          rabbitmq_queue    => 'spectest_queue',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
    describe port(5673) do
      it { should be_listening }
    end
  end
end
