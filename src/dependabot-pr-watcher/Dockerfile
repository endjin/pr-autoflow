FROM alpine/git as module_builder
WORKDIR /tmp
ARG branch=master
RUN git clone https://github.com/endjin/dependabot-pr-parser-powershell \
        && cd dependabot-pr-parser-powershell \
        && git checkout ${branch}

FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.8
COPY --from=module_builder /tmp/dependabot-pr-parser-powershell/src/ ./tmp/module/
COPY . ./tmp/
ENTRYPOINT ["pwsh","-File","/tmp/RunAction.ps1"]
