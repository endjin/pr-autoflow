FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.8
COPY . /tmp/
RUN pwsh -f /tmp/prepare-module.ps1
ENTRYPOINT ["pwsh","-File","/tmp/entrypoint.ps1"]
