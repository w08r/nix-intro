# Spark, Mill and the JDK

The flake in this directory showcases using package overrides.

If you wanted to set up an environment where you could develop a spark
application, you might start by pulling in the packages jdk, spark,
and maybe mill for building.  The problem is that the underlying jdk
or runtime version may be different in these 3 cases.  While that
could potentially work, it can lead to issues in places.

The mill package takes a jre attribute argument which means the jre
package it uses can be specified (and therefore overridden).

```
        mymill = p.mill.override {
            jre = j;
        };
```

Lets check that mill and spark use the same jdk:

```
➜ nix derivation show .#mill .#spark | jq '.[]|.inputDrvs|keys|.[]|select(match("zulu"))'     
"/nix/store/d3byxc15nwcz2h0ansd74ngagi9smzjz-zulu-ca-jdk-11.0.22.drv"
"/nix/store/d3byxc15nwcz2h0ansd74ngagi9smzjz-zulu-ca-jdk-11.0.22.drv"
```

And that's the same derivation as the local jdk:

```
➜ nix derivation show .#jdk | jq 'keys[]'
"/nix/store/d3byxc15nwcz2h0ansd74ngagi9smzjz-zulu-ca-jdk-11.0.22.drv"
```

Et Voilà!
