using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using ZXing;
using ZXing.Common;

namespace PrepReady.Helpers
{
    /// <summary>
    /// Generates a QR-code PNG using ZXing.Net. Uses BarcodeWriterPixelData
    /// (renderer-agnostic) so it works on .NET Framework via System.Drawing.
    /// </summary>
    public static class QrHelper
    {
        public static byte[] GeneratePng(string text, int size = 240)
        {
            var writer = new BarcodeWriterPixelData
            {
                Format = BarcodeFormat.QR_CODE,
                Options = new EncodingOptions { Width = size, Height = size, Margin = 1 }
            };

            var pixelData = writer.Write(text);

            using (Bitmap bmp = new Bitmap(pixelData.Width, pixelData.Height, PixelFormat.Format32bppArgb))
            {
                BitmapData data = bmp.LockBits(
                    new Rectangle(0, 0, pixelData.Width, pixelData.Height),
                    ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                try
                {
                    Marshal.Copy(pixelData.Pixels, 0, data.Scan0, pixelData.Pixels.Length);
                }
                finally
                {
                    bmp.UnlockBits(data);
                }

                using (MemoryStream ms = new MemoryStream())
                {
                    bmp.Save(ms, ImageFormat.Png);
                    return ms.ToArray();
                }
            }
        }
    }
}