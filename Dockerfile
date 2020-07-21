FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.8

COPY ./src/ ./tmp/

ENTRYPOINT ["pwsh","-File","/tmp/RunAction.ps1"]
