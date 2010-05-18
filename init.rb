require 'redmine'

Redmine::Plugin.register :redmine_estimates do
  name 'Redmine Estimates plugin'
  author 'Charlie Savage'
  description 'This plugin summarizes estimated (and actual) ticket times on a calendar view.'
  version '0.0.1'

  controller_options = {:controller => 'estimate',
                        :action => 'show' }

  menu(:account_menu, :estimate, controller_options, :caption => :label_estimates)
  menu(:project_menu, :estimate, controller_options, :caption => :label_estimates,
                                                     :after => :roadmap,
                                                     :param => 'project_id')

  # Module/Permissions
  project_module :estimates do
    permission(:view_estimates, :estimate => :show)
  end
end
