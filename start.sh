#!/bin/bash
# Used as a start script for the docker image
MIX_ENV=prod mix ecto.migrate && iex -S mix phoenix.server
