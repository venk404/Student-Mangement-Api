.ONESHELL:
VENV := venv

all: install Schema-creation run

# Define the installation steps
install: $(VENV)\Scripts\activate

$(VENV)\Scripts\activate: requirements.txt
	python -m venv $(VENV)

ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\activate.ps1
	$(VENV)\Scripts\python -m pip install --upgrade pip
	$(VENV)\Scripts\pip install -r requirements.txt
else
	chmod +x $(VENV)/bin/activate
	source $(VENV)/bin/activate
	$(VENV)/bin/python -m pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
endif

Schema-creation:
ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\pyway migrate --config DB\Schemas\pyway.conf 
else
	$(VENV)/bin/pyway migrate --config DB/Schemas/pyway.conf
endif

# Define the run step
run:
ifeq ($(OS),Windows_NT)
	$(VENV)/Scripts/python "code\Main.py" --reload
else
	$(VENV)/bin/python "code/Main.py" --reload
endif

# Define a clean step
clean:
ifeq ($(OS),Windows_NT)
	@powershell -Command "Get-ChildItem -Recurse -Directory -Filter '__pycache__' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -Recurse -Directory -Filter 'data' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -Recurse -Directory -Filter 'venv' | Remove-Item -Recurse -Force"
else
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name "data" -exec rm -rf {} +
	find . -type d -name "venv" -exec rm -rf {} +
endif

test:
ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\python test/test.py
else:
	$(VENV)\bin\python test/test.py
endif


.PHONY: install run clean reinstall test

