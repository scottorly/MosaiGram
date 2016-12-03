Sample IBM Kitura application that can be easily deployed to Pivotal Web Services (or any Cloud Foundry environment).

**Download the Xcode 8 beta from Apple**

- In Xcode 8 beta preferences (`cmd + ,`) set command line tools to Xcode 8.0
![alt text](https://cloud.githubusercontent.com/assets/1342803/17273391/51d2e1ee-5681-11e6-8460-982ccc55f758.png)


**Install swiftenv**

- `$ git clone https://github.com/kylef/swiftenv.git ~/.swiftenv`

- add following to Bash profile

``` bash
export SWIFTENV_ROOT="$HOME/.swiftenv"

export PATH="$SWIFTENV_ROOT/bin:$PATH"

eval "$(swiftenv init -)"```

 - Install 8-23 development snapshot:

 `$ swiftenv install DEVELOPMENT-SNAPSHOT-2016-08-23-a`

 - Verify the swift version:

 `$ swiftenv version`

 - Generate Xcode project:

 `$ swift package generate-xcodeproj`

- In Xcode set the toolchain to `DEVELOPMENT-SNAPSHOT-2016-08-23-a`

![alt-text](https://developer.apple.com/library/ios/recipes/xcode_help-documentation_preferences/Art/xcode_componentspreferences_window_toolchains_tab_2x.png)

**Install Cloud Foundry CLI...** https://cli.run.pivotal.io/stable?release=macosx64&source=pws

...and deploy: `$ cf push <app-name> -b https://github.com/ScottORLY/swift-buildpack.git`

Enjoy!

https://github.com/IBM-Swift/Kitura

https://github.com/kylef/swiftenv

https://github.com/Swinject/Swinject

https://run.pivotal.io
