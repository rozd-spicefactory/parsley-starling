/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 12:57 PM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.filter
{
import avmplus.getQualifiedClassName;

import org.spicefactory.parsley.core.view.ViewAutowireMode;

import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.view.impl.AbstractViewAutowireFilter;

import starling.events.Event;

public class StarlingViewAutowireFilter extends AbstractViewAutowireFilter
{
    private var excludedTypes:RegExp = /^starling\.|^feathers\.|^flash\./;

    public function StarlingViewAutowireFilter()
    {
        super();

        this.eventType = Event.ADDED;
    }

    /**
     * @inheritDoc
     */
    public override function prefilter(object:Object):Boolean
    {
        return !excludedTypes.test(getQualifiedClassName(object));
    }

    /**
     * @inheritDoc
     */
    public override function filter(object:Object):ViewAutowireMode
    {
        return ViewAutowireMode.CONFIGURED;
    }
}
}
