image_name := "gentoo-overlay-test"

build:
    docker build -f Dockerfile.test -t {{image_name}} .

test-lint: build
    docker run --rm {{image_name}} pkgcheck scan --net

test-build package: build
    docker run --rm --network=host {{image_name}} \
        emerge --verbose --oneshot '={{package}}' 2>&1

test-shell package="": build
    @if [ -n "{{package}}" ]; then \
        docker run -it --rm --network=host {{image_name}} \
            bash -c 'emerge --verbose --oneshot ={{package}} 2>&1; exec bash'; \
    else \
        docker run -it --rm --network=host {{image_name}} bash; \
    fi

test: test-lint

clean:
    docker rmi {{image_name}} 2>/dev/null || true
