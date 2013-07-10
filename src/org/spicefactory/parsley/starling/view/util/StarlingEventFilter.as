/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 1:15 PM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.util
{
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * Filters re-parenting events for Starling's DisplayObject.
 *
 * This implementation uses <i>added</i>/<i>removed</i> events for view
 * management instead of <i>addedToStage</i>/<i>removeFromStage</i>, the reason
 * is Starling dispatches bubbling events only for first pair.
 *
 * @see org.spicefactory.parsley.core.view.util.StageEventFilter
 */
public class StarlingEventFilter
{
    /**
     * Creates a new instance that filters events for the specified view.
     *
     * @param view the view for which to filter stage events
     * @param removedHandler the handler to invoke for filtered removed events
     * @param removedHandler the handler to invoke for filtered added events
     */
    function StarlingEventFilter(view:DisplayObject, removedHandler:Function, addedHandler:Function = null)
    {
        this.view = view;
        this.removedHandler = removedHandler;
        this.addedHandler = addedHandler;

        view.addEventListener(Event.ADDED, added);
        view.addEventListener(Event.REMOVED, removed);
    }

    private var view:DisplayObject;
    private var removedHandler:Function;
    private var addedHandler:Function;

    private var addedInCurrentFrame:Boolean;
    private var removedInCurrentFrame:Boolean;

    /**
     * Instructs this filter to stop listening to stage events.
     */
    public function dispose():void
    {
        view.removeEventListener(Event.ADDED, added);
        view.removeEventListener(Event.REMOVED, removed);
        view.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function resetFrame():void
    {
        addedInCurrentFrame = false;
        removedInCurrentFrame = false;

        view.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function added(event:Event):void
    {
        if (event.target != view) // ignore bubbling
            return;

        if (removedInCurrentFrame)
        {
            resetFrame();
        }
        else
        {
            addedInCurrentFrame = true;
            view.addEventListener(Event.ENTER_FRAME, enterFrame)
        }
    }

    private function removed(event:Event):void
    {
        if (event.target != view) // ignore bubbling
            return;

        if (addedInCurrentFrame)
        {
            resetFrame();
        }
        else
        {
            removedInCurrentFrame = true;
            view.addEventListener(Event.ENTER_FRAME, enterFrame);
        }
    }

    private function enterFrame(event:Event):void
    {
        if (addedInCurrentFrame)
        {
            if (addedHandler != null)
                addedHandler(view);
        }
        else if (removedInCurrentFrame)
        {
            removedHandler(view);
        }

        resetFrame();
    }
}
}
