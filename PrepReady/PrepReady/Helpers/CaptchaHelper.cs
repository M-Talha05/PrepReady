using System;
using System.Web;

namespace PrepReady.Helpers
{
    /// <summary>Simple session-based math CAPTCHA (no external service needed).</summary>
    public static class CaptchaHelper
    {
        private const string Key = "CaptchaAnswer";

        public static string NewQuestion()
        {
            Random r = new Random();
            int a = r.Next(2, 9);
            int b = r.Next(2, 9);
            HttpContext.Current.Session[Key] = a + b;
            return "What is " + a + " + " + b + "?";
        }

        public static bool IsValid(string input)
        {
            object stored = HttpContext.Current.Session[Key];
            if (stored == null) return false;
            int val;
            return int.TryParse((input ?? "").Trim(), out val) && val == (int)stored;
        }
    }
}