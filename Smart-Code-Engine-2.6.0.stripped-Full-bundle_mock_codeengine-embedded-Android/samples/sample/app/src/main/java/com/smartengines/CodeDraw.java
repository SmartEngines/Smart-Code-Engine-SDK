/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.smartengines.code.CodeEngineFeedbackContainer;
import com.smartengines.code.CodeEngineResult;
import com.smartengines.code.CodeObject;
import com.smartengines.code.CodeObjectsMapIterator;
import com.smartengines.common.Quadrangle;
import com.smartengines.common.QuadranglesMapIterator;
import com.smartengines.common.Rectangle;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

public class CodeDraw extends View {

  public static float scale = 1f;
  public static float translate_y = 0;
  public static float translate_x = 0;

  static class QuadStorage {
    private final float[] points = new float[16];
    private int color = Color.WHITE;
    private Paint paint = new Paint();

    QuadStorage(Quadrangle quad) {
      points[0] = (float) quad.GetPoint(0).getX() * scale + translate_x;
      points[1] = (float) quad.GetPoint(0).getY() * scale + translate_y;
      points[2] = (float) quad.GetPoint(1).getX() * scale + translate_x;
      points[3] = (float) quad.GetPoint(1).getY() * scale + translate_y;
      points[4] = (float) quad.GetPoint(1).getX() * scale + translate_x;
      points[5] = (float) quad.GetPoint(1).getY() * scale + translate_y;
      points[6] = (float) quad.GetPoint(2).getX() * scale + translate_x;
      points[7] = (float) quad.GetPoint(2).getY() * scale + translate_y;
      points[8] = (float) quad.GetPoint(2).getX() * scale + translate_x;
      points[9] = (float) quad.GetPoint(2).getY() * scale + translate_y;
      points[10] = (float) quad.GetPoint(3).getX() * scale + translate_x;
      points[11] = (float) quad.GetPoint(3).getY() * scale + translate_y;
      points[12] = (float) quad.GetPoint(3).getX() * scale + translate_x;
      points[13] = (float) quad.GetPoint(3).getY() * scale + translate_y;
      points[14] = (float) quad.GetPoint(0).getX() * scale + translate_x;
      points[15] = (float) quad.GetPoint(0).getY() * scale + translate_y;

      paint.setColor(color);
      paint.setStrokeWidth(4);
    }

    public float[] getPoints() { return points; }
    public Paint getPaint() {return paint;}
  }

  private final Paint paint = new Paint();

  private final int historyLength = 5;
  private final List<Set<QuadStorage>> quads = new LinkedList<>();

  public CodeDraw(Context context) {
    super(context);
    initView();
  }

  public CodeDraw(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    initView();
  }

  private void initView() {
    paint.setColor(Color.WHITE);
    paint.setStrokeWidth(3);
    paint.setAntiAlias(true);
  }

  public void showCodeMatching(CodeEngineFeedbackContainer feedbackContainer)
  {
    Set<QuadStorage> qs = new HashSet<>();

    for (QuadranglesMapIterator q_it = feedbackContainer.QuadranglesBegin();
         !q_it.Equals(feedbackContainer.QuadranglesEnd()); q_it.Advance()) {
        qs.add(new QuadStorage(q_it.GetValue()));
    }

    if(quads.size() == historyLength)
      quads.remove(0);

    quads.add(qs);
  }

  public void cleanUp() {
    quads.clear();
    invalidate();
  }

  @Override
  protected void onDraw(@NonNull Canvas canvas) {
    super.onDraw(canvas);
    // canvas.translate(translate_x * scale, translate_y * scale);
    int nq = quads.size();
    for (int i = 0; i < nq; i++) {
      for (QuadStorage q : quads.get(i)) {
        int currentAlpha = q.getPaint().getAlpha();
        if (currentAlpha > 0) {
          int newAlpha = Math.max(currentAlpha - 20, 0); // Decrease alpha by 20
          q.getPaint().setAlpha(newAlpha);
          canvas.drawLines(q.getPoints(), q.getPaint());
        }
      }
    }



  }

}

