#
# This class implements a tabbed navigation bar. When one item in the navigation is clicked
# it displays the tab that corresponds to that 
#
# Example usage:
# new new Lale.TabNav('.tab-nav', '.tab')
#
class Lale.TabNav
  constructor: (nav_selector, tabs_selector) ->
    this.navLinks  = $(nav_selector).find('a')
    this.tabs      = $(tabs_selector)
    first_tab      = this.navLinks.first().data('tab')
    this.showTab(first_tab)
    this.navLinks.on 'click', (event) =>
      this.handleTabNavClick(event)

  handleTabNavClick: (event) ->
    name = $(event.target).closest('a').data('tab')
    this.showTab(name)

  showTab: (name) ->
    # update look of nav
    this.navLinks.removeClass('selected').filter("." + name).addClass('selected')
    # toggle tabs
    this.tabs.hide().filter("." + name).show()
