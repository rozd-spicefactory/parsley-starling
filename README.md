parsley-starling
================

Enables Parsley for Starling projects

**NOTE**: This library requires modified version of Parsley from [rozdonmobile/parsley-core](https://github.com/rozdonmobile/parsley-starling)

## Implementation Notes
* Requires modified version of Parsley with less dependency on Flash prebuilt classes such as DisplayObject and Event. it could be founf here [rozdonmobile/parsley-core](https://github.com/rozdonmobile/parsley-starling)
* Configuration process is triggered by `Event.ADDED` event, instead of `Event.ADDED_TO_STAGE` as in standard Flash implementation of Parsley. It is due to Starling dispatches `Event.ADDED_TO_STAGE` without _bubbles_ flag.

## Usage

### For explicit wiring

During configuration add `StarlingViewManagerDecorator` ViewManager decorator and pass Starling istance to it:

```actionscript
ContextBuilder.newSetup()
    .services()
        .viewManager()
            .addDecorator(StarlingViewManagerDecorator, _starling)
    .newBuilder()
        .config(XmlConfig.forFile("config.xml"))
    .build();
```

Use `StarlingConfigure` class to add specified View into Parsley's Context:
  
```
import feathers.controls.Screen
public class NewsView extends Screen
{
    public function NewsView()
    {
        super();

        StarlingConfigure.view(this).execute();
    }
}
```

### For automatic wiring

Enable Parsley's _autowiring_ feature and change default ViewAutowireFilter implementation to `StarlingViewAutowireFilter`:
```actionscript
BootstrapDefaults.config.viewSettings.autowireComponents = true;
BootstrapDefaults.config.viewSettings.autowireFilter = new StarlingViewAutowireFilter();
```
Configure Parsley with Starling support:
```actionscript
ContextBuilder.newSetup()
    .services()
        .viewManager()
            .addDecorator(StarlingViewManagerDecorator, _starling)
    .newBuilder()
        .config(XmlConfig.forFile("config.xml"))
    .build();
```

In your `config.xml` define some View:

```xml
<?xml version="1.0"?>
<objects
        xmlns="http://www.spicefactory.org/parsley"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.spicefactory.org/parsley
        http://www.spicefactory.org/parsley/schema/3.0/parsley-core.xsd"
        >

    <view type="com.example.presentation.MessagesView">

    </view>

</objects>
```
