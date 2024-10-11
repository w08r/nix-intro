{
  description = "Spark flake; mill for builds";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        p = nixpkgs.legacyPackages.${system};
        j = p.hadoop.jdk;
        mymill = p.mill.override {
            jre = j;
        };
        myam = p.ammonite_2_12.override {
            jre = j;
        };
      in
        {
          packages = {
            mill = mymill;
            jdk = j;
            spark = p.spark;
          };
          devShells = rec {
            default = p.mkShell {
              packages = [
                myam
                mymill
                j
                p.spark
              ];
              shellHook=''
                export SPARK_LOG_DIR=$PWD/spark-logs
                export SPARK_LOCAL_DIRS=$PWD/spark-local
                export SPARK_WORKER_DIR=$PWD/spark-worker
              '';
            };
          };
        }
    );
}
