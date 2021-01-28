FROM pandoc/latex

LABEL  maintainer="Jon Oster <jon.i.oster@gmail.com>"

# Install python3, pip, and pandoc-include
RUN apk update && \
    apk add py3-pip && \
    pip install pandoc-include

WORKDIR /data

ENTRYPOINT ["pandoc"]
CMD ["--help"]

