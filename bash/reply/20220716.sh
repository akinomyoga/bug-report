#!/usr/bin/env bash
set -e; T(){ local -r v=T; }; trap T 0; F() { local -r v=F; exit 0; }; F
