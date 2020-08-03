FROM alpine/git as module_builder
WORKDIR /tmp
ARG repoUrl=https://github.com/endjin/pr-autoflow
ARG branch=master
RUN git clone ${repoUrl} \
        && cd pr-autoflow \
        && git checkout ${branch}

FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.8
COPY --from=module_builder /tmp/pr-autoflow/module/ /tmp/module/
COPY --from=module_builder /tmp/pr-autoflow/module/entrypoint.ps1 /tmp/
COPY . /tmp/
ENTRYPOINT ["pwsh","-File","/tmp/entrypoint.ps1"]
