# ------------------------------------------------------------------------
#
# General stuff
#

# Detect OS
OS = $(shell uname -s)

# Default echo
ECHO = echo

# Make adjustments based on OS
ifneq (, $(findstring CYGWIN, $(OS)))
	ECHO = /bin/echo -e
endif

# Text colors
NO_COLOR	 = \033[0m
ACTION_COLOR = \033[0;49;33m
HELP_COLOR   = \033[4;49;96m
OK_COLOR	 = \033[32;01m
ERROR_COLOR	 = \033[31;01m
WARN_COLOR	 = \033[33;01m

# Which makefile am I in?
WHERE-AM-I = $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_MAKEFILE := $(call WHERE-AM-I)


# Echo some nice helptext based on the target comment
HELPTEXT = $(ECHO) "$(HELP_COLOR)"`egrep "^\# target: $(1) " $(THIS_MAKEFILE) | sed "s/\# target: $(1)[ ]*-[ ]* //g"`"$(NO_COLOR)"

# Echo Help text but ignore \n so that tests can display result on same line.
TESTTEXT = bash -c '$(ECHO) -ne "$(ACTION_COLOR) > "`egrep "^\# target: $(1) " $(THIS_MAKEFILE) | sed "s/\# target: $(1)[ ]*-[ ]* //g"`".. $(NO_COLOR)"'

# Used for displaying information about what is being done during target.
ACTION = $(ECHO) " > $(ACTION_COLOR)$(1)$(NO_COLOR)"


# ------------------------------------------------------------------------
#
# Main Targets
#


# target: help               - Displays this help message.
.PHONY:  help
help:
	@$(ECHO) "Usage:"
	@$(ECHO) " make [target] ..."
	@$(ECHO) "target:"
	@egrep "^# target:" $(THIS_MAKEFILE) | sed 's/# target: / /g'

# target: install            - Install dependencies.
.PHONY: install
install:
	@$(call HELPTEXT,$@)
	@$(call ACTION,Installing dependencies...)
	@npm install

# target: update             - Update dependencies.
.PHONY: update
update:
	@$(call HELPTEXT,$@)
	@$(call ACTION,Updating dependencies...)
	@npm update

# target: reinstall          - Reinstall dependencies.
.PHONY: reinstall
reinstall:
	@$(call HELPTEXT,$@)
	@$(call ACTION,Removing node_modules...)
	@rm -rf node_modules
	@$(call ACTION,Installing dependencies...)
	@npm install

# target: start-docker       - Start App in Docker.
.PHONY: start-docker
start-docker:
	@$(call HELPTEXT,$@)
	@bash -c "docker-compose up node-latest"

# target: test               - Run all tests.
.PHONY: test
test: test-help jscs eslint stylelint csslint jsunittest

.PHONY: test-help
test-help:
	@$(ECHO) "$(HELP_COLOR)Run all tests.$(NO_COLOR)"

# target: test-node-latest   - Run all tests with latest Node in Docker.
.PHONY: test-node-latest
test-node-latest:
	@$(call HELPTEXT,$@)
	@$(call ACTION,Starting Docker...)
	@bash -c "docker-compose run node-latest make test"

# target: test-node-9        - Run all tests with Node 9 in Docker.
.PHONY: test-node-9
test-node-9:
	@$(call HELPTEXT,$@)
	@$(call ACTION,Starting Docker...)
	@bash -c "docker-compose run node-9 make test"

# target: test-node-8        - Run all tests with Node 8 in Docker.
.PHONY: test-node-8
test-node-8:
	@$(call HELPTEXT,$@)
	@$(call ACTION,Starting Docker...)
	@bash -c "docker-compose run node-8 make test"


# ------------------------------------------------------------------------
#
# Tests
#



# target: csslint            - CSS lint.
.PHONY: csslint
csslint:
	@$(call TESTTEXT,$@)
	@[ ! -f .csslintrc ] || node_modules/.bin/csslint .
	@$(ECHO) "$(OK_COLOR)OK$(NO_COLOR)"

# target: stylelint          - Style lint.
.PHONY: stylelint
stylelint:
	@$(call TESTTEXT,$@)
	@[ ! -f .stylelintrc.json ] || node_modules/.bin/stylelint **/*.css
	@$(ECHO) "$(OK_COLOR)OK$(NO_COLOR)"

# target: jscs               - JavaScript code style.
.PHONY: jscs
jscs:
	@$(call TESTTEXT,$@)
	@[ ! -f .jscsrc ] || node_modules/.bin/jscs .
	@$(ECHO) "$(OK_COLOR)OK$(NO_COLOR)"

# target: eslint             - JavaScript lint.
.PHONY: eslint
eslint:
	@$(call TESTTEXT,$@)
	@[ ! -f .eslintrc.json ] || node_modules/.bin/eslint .
	@$(ECHO) "$(OK_COLOR)OK$(NO_COLOR)"

# target: jsunittest         - JavaScript unit tests.
.PHONY: jsunittest
jsunittest:
	@$(call TESTTEXT,$@)
	@node_modules/.bin/nyc --reporter=html --reporter=text node_modules/.bin/mocha 'test/**/*.js'
	@$(ECHO) ""
