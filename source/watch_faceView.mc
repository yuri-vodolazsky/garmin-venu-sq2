import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class watch_faceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);

        // Motto
        var mottoLabel = View.findDrawableById("MottoLabel") as Text;
        mottoLabel.setText("T I M E  TO  C O D E !");

        // Date
        var dateLabel = View.findDrawableById("DateLabel") as Text;
        dateLabel.setText(getDate());

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var WIDTH = dc.getWidth();
        var HEIGHT = dc.getHeight();
        var LINEWIDTH = 4;
        var LINEGAP = 5;
        var ratio;

        ratio = getRatioThresholded(getActiveMinutesWeek(), getActiveMinutesWeekGoal());
        drawProgressBar(dc, WIDTH, HEIGHT, LINEWIDTH, LINEGAP, Graphics.COLOR_ORANGE, Graphics.COLOR_LT_GRAY, ratio, 0);

        ratio = getRatioThresholded(getSteps(), getStepGoal());
        drawProgressBar(dc, WIDTH, HEIGHT, LINEWIDTH, LINEGAP, Graphics.COLOR_DK_BLUE, Graphics.COLOR_LT_GRAY, ratio, 1);

        ratio = getRatioThresholded(getCalories(), getCaloriesGoal());
        drawProgressBar(dc, WIDTH, HEIGHT, LINEWIDTH, LINEGAP, Graphics.COLOR_RED, Graphics.COLOR_LT_GRAY, ratio, 2);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }


    // Draw helpers

    function drawProgressBar(dc as Dc, width, height, lineWidth, lineGap, color, bgColor, ratio, position) as Void {
        dc.setPenWidth(lineWidth);
        var stepBarY = height - lineWidth - (lineWidth + lineGap) * position;

        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, stepBarY, width, stepBarY);

        if (ratio > 0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(0, stepBarY, width * ratio, stepBarY);
        }
    }

    // Data helpers

    function getDate() as String {
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$ $3$",         [
                now.day_of_week,
                now.day,
                now.month,
            ]
        );
        return dateString;
    }

    function getSteps() as Number {
        return getNullAsZero(
            Toybox.ActivityMonitor.getInfo().steps
        );
    }

    function getStepGoal() as Number {
        return getNullAsZero(
            Toybox.ActivityMonitor.getInfo().stepGoal
        );
    }

    function getCalories() as Number {
        return getNullAsZero(
            Toybox.ActivityMonitor.getInfo().calories
        );
    }

    function getCaloriesGoal() as Number {
        return 3200;
    }

    function getActiveMinutesWeek() as Number {
        return getNullAsZero(
            Toybox.ActivityMonitor.getInfo().activeMinutesWeek.total
        );
    }

    function getActiveMinutesWeekGoal() as Number {
        return getNullAsZero(
            Toybox.ActivityMonitor.getInfo().activeMinutesWeekGoal
        );
    }

    // Calc helpers

    function getRatioThresholded(value, goal) as Float {
        if (goal == 0) {
            return 0.0;
        }

        if (value > goal) {
            value = goal;
        }

        return 1.0 * value / goal;
    }

    function getNullAsZero(value) as Number or Null {
        if (value == null) {
            return 0;
        } else {
            return value;
        }
    }
}
