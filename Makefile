NAME := docs
INSTALL_STAMP := .install.stamp
POETRY := $(shell command -v poetry 2> /dev/null)
.DEFAULT_GOAL := help

.PHONY: help
help:
		@echo "Please use 'make <target>' where <target> is one of"
		@echo ""
		@echo "  install     install packages and prepare environment"
		@echo "  clean       remove all temporary files"
		@echo "  lint        run the code linters"
		@echo "  format      reformat code"
		@echo "  test        run all the tests"
		@echo ""
		@echo "Check the Makefile to know exactly what each target is doing."

install: $(INSTALL_STAMP)
$(INSTALL_STAMP): pyproject.toml poetry.lock
		@if [ -z $(POETRY) ]; then echo "Poetry could not be found. See https://python-poetry.org/docs/"; exit 2; fi
		$(POETRY) install
		touch $(INSTALL_STAMP)

.PHONY: clean
clean:
		find . -type d -name "__pycache__" | xargs rm -rf {};
		rm -rf $(INSTALL_STAMP) .coverage .mypy_cache

.PHONY: lint
lint: $(INSTALL_STAMP)
		$(POETRY) run isort --profile=black --lines-after-imports=2 --check-only $(NAME)
		$(POETRY) run black --check $(NAME) --diff
		$(POETRY) run flake8 --ignore=W503,E501 $(NAME)
		$(POETRY) run mypy $(NAME) --ignore-missing-imports
		$(POETRY) run bandit -r $(NAME) -s B608

.PHONY: format
format: $(INSTALL_STAMP)
		$(POETRY) run autoflake --remove-all-unused-imports -i -r $(NAME) --exclude=__init__.py 
		$(POETRY) run isort --profile=black --lines-after-imports=2 $(NAME)
		$(POETRY) run black $(NAME)