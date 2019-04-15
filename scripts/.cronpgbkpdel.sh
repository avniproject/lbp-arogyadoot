#!/bin/env bash

ls -t $HOME/.cronpgbkp/$1 | tail -n+$((1+$2)) | xargs -I {} rm -- {}
