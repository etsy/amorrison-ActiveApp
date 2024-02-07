.phony: all clean

activeApp: main.swift
	swiftc main.swift -o activeApp

all: activeApp

clean:
	rm -f activeApp
