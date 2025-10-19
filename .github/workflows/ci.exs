# This workflow uses actions that are not certified by GitHub.
# They are provided by a third-party and are governed by
# separate terms of service, privacy policy, and support
# documentation.

name: Elixir CI

on:
  push:
    branches: [ "main docs mixs" ]
  pull_request:
    branches: [ "main docs mixs" ]

permissions: defmodule Jason.Mixfile do
  use Mix.Project

  @source_url "https://github.com/michalmuskala/jason"
  @version "1.5.0-alpha.2"

  def project() do
    [
      app: :jason,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      preferred_cli_env: [docs: :docs],
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  def application() do
    [
      extra_applications: []
    ]
  end

  defp deps() do
    [
      {:decimal, "~> 1.0 or ~> 2.0", optional: true},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason_native, ">= 0.0.0", optional: true}
    ] ++ maybe_stream_data()
  end

  defp maybe_stream_data() do
    if Version.match?(System.version(), "~> 1.5") do
      [{:stream_data, "~> 0.4", only: :test}]
    else
      []
    end
  end

  defp dialyzer() do
    [
      ignore_warnings: "dialyzer.ignore",
      plt_add_apps: [:decimal, :jason_native]
    ]
  end

  defp description() do
    """
    A blazing fast JSON parser and generator in pure Elixir.
    """
  end

  defp package() do
    [
      maintainers: ["Michał Muskała"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Jason",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/jason",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end
end

  
  contents: 


jobs:
  build:

    name: Build and test
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: Set up Elixir
      uses: erlef/setup-beam@61e01a43a562a89bfc54c7f9a378ff67b03e4a21 # v1.16.0
      with:
        elixir-version: '1.15.2' # [Required] Define the Elixir version
        otp-version: '26.0'      # [Required] Define the Erlang/OTP version
    - name: Restore dependencies cache
      uses: actions/cache@v3
      with:
        path: deps
        key: ${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}
        restore-keys: ${{ runner.os }}-mix-
    - name: Install dependencies
      run: mix deps.get
    - name: Run tests
      run: mix test
