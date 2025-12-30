package com.smartengines;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.ViewGroup;

import com.smartengines.common.Rectangle;

public class Viewport extends ViewGroup {

    public final static float w_scale = 0.95F; // left and right paddings
    public final static float h_scale = 0.5F;

    public static float view_rect_width;
    public static float view_rect_height;
    public static  RectF ViewRoiRect;

    public Viewport(Context context) {
        super(context);
    }

    public Viewport(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public Viewport(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

//    @Override
//    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
//        setMeasuredDimension(widthMeasureSpec, heightMeasureSpec);
//        view_rect_width = MeasureSpec.getSize(widthMeasureSpec) * w_scale;
//        view_rect_height = view_rect_width * h_scale;
//    }

    @Override
    public void onLayout(boolean changed, int left, int top, int right, int bottom) {
    }

    @Override
    public boolean shouldDelayChildPressedState() {
        return false;
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);

        // view resize is incomplete and the width is not ready
        if (getWidth() == 0)
            return;

        int viewportCornerRadius = 6;
        Paint eraser = new Paint();
        eraser.setAntiAlias(true);
        eraser.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));
        ViewRoiRect = getViewRoiRectangle(getHeight(), getWidth());

        Paint paint = new Paint();
        paint.setColor(Color.WHITE);
        paint.setTextSize(40);
        boolean ratio = (view_rect_width / view_rect_height) == 2.0;
        canvas.drawText("RATIO: " + (ratio ? "2:1" : "Not 2:1"), ViewRoiRect.left,  ViewRoiRect.top - 10, paint);
        canvas.drawRoundRect(ViewRoiRect, (float) viewportCornerRadius, (float) viewportCornerRadius, eraser);
    }

    private static RectF getViewRoiRectangle(int h, int w) {
        // get center points
        float center_x = (float) (h / 2.0);
        float center_y = (float) (w / 2.0);

        // get top x and y coords for draw rectangle
        float topX = (float) (center_x - (view_rect_height / 2.0));
        float topY = (float) (center_y - (view_rect_width / 2.0));

        return new RectF(topY, topX, topY + view_rect_width, topX + view_rect_height);
    }

    public static Rectangle getCropRoiRectangle(int img_h, int img_w, int frame_w) {

         // get center points
        float center_x = (float) (img_w / 2.0);
        float center_y = (float) (img_h / 2.0);

        // calc crop rectangle as viewport size ratio
        int crop_w = (int) (frame_w * Viewport.w_scale);
        int crop_h = (int) (crop_w * Viewport.h_scale);

        // get top x and y coords for draw rectangle
        double topX = center_x - (crop_w / 2.0);
        double topY = center_y - (crop_h / 2.0);

        // top X, top Y, width, height
        return new Rectangle((int) topX, (int) topY, crop_w, crop_h);
    }

    public static void setRoiRectSize(int frameWidth) {
        /** Image size for phone and card numbers must be 2/1 ratio! */
        view_rect_width = frameWidth * Viewport.w_scale;
        view_rect_height = view_rect_width * Viewport.h_scale;
    }

}
