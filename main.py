from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from PIL import Image
from pynput.keyboard import Controller
import os, io, sys, threading
import pytesseract

size = (800, 200)
border = (8, 50, 8, 8) # (left, top, right, bottom)

class Window(QMainWindow):
    def __init__(self):
        super().__init__()

        # Set window title and size
        self.setWindowTitle("Writeboard")
        self.setGeometry(100, 100, size[0], size[1])

        # Create image objects
        self.background = QImage(size[0], size[1], QImage.Format_RGB32)
        self.image = QImage(size[0], size[1], QImage.Format_ARGB32)
        self.boundingbox = QImage(size[0], size[1], QImage.Format_ARGB32)
        self.foreground = QImage(size[0], size[1], QImage.Format_ARGB32)

        # Set color of image objects
        self.background.fill(QColor.fromRgb(83, 83, 83))
        self.foreground.fill(Qt.transparent)
        self.image.fill(Qt.transparent)
        self.boundingbox.fill(Qt.transparent)

        self.textLabel = QLabel(self)
        self.textLabel.setGeometry(QRect(border[0], 0, size[0], border[1]))
        self.textLabel.setFont(QFont("Noto Sans", 12))
        self.textLabel.mousePressEvent = self.writeEvent

        self.keyboard = Controller()

        # Guiding line
        painter = QPainter(self.background)
        painter.setPen(QPen(QColor.fromRgb(255, 255, 255, 128),
                       1, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))
        painter.drawLine(int(0.02*self.width()), int(0.8*self.height()),
                         int(0.98*self.width()), int(0.8*self.height()))

        # Fill the foreground (border)
        painter = QPainter(self.foreground)
        painter.fillRect(0, 0, border[0], size[1], QColor.fromRgb(68, 68, 68)) # Left border
        painter.fillRect(size[0]-border[2], 0, border[2], size[1], QColor.fromRgb(68, 68, 68)) # Right border
        painter.fillRect(0, 0, size[0], border[1], QColor.fromRgb(68, 68, 68)) # Top border
        painter.fillRect(0, size[1]-border[3], size[0], border[3], QColor.fromRgb(68, 68, 68)) # Bottom border

        # Brush variables
        self.drawing = False
        self.brushSize = 4
        self.brushColor = Qt.white

        # QPoint object to track the point
        self.lastPoint = QPoint()

        self.setWindowFlags(Qt.FramelessWindowHint |
                            Qt.WindowStaysOnTopHint | Qt.WindowDoesNotAcceptFocus)

    def mousePressEvent(self, event):

        if event.button() == Qt.LeftButton:
            self.drawing = True
            self.lastPoint = event.pos()

    def mouseMoveEvent(self, event):
        if (event.buttons() & Qt.LeftButton) & self.drawing:
            # Create painter object and pen
            painter = QPainter(self.image)
            painter.setPen(QPen(self.brushColor, self.brushSize,
                                Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))

            # Draw a line from the last point, then update last point
            painter.drawLine(self.lastPoint, event.pos())
            self.lastPoint = event.pos()
            
            self.update()

    def writeEvent(self, event):
        self.keyboard.type(self.textLabel.text())
        self.clear()


    def ocr(self, buffer):
        pil_im = Image.open(io.BytesIO(buffer.data())).convert('RGBA')
        pil_im = pil_im.crop((border[0], border[1], size[0]-border[2], size[1]-border[3]))
        background = Image.new('RGBA', pil_im.size, (83, 83, 83))
        sc_img = Image.alpha_composite(background, pil_im)

        text = pytesseract.image_to_string(sc_img, lang="dhw", config=f"--tessdata-dir {os.path.dirname(__file__)}/traineddata")
        ocr_data = pytesseract.image_to_data(
            sc_img, lang="dhw", output_type=pytesseract.Output.DICT)
        painter = QPainter(self.boundingbox)
        self.boundingbox.fill(Qt.transparent)
        for x in range(len(ocr_data["text"])):
            if ocr_data["text"][x] != "":
                painter.drawRect(
                    ocr_data["left"][x] + border[0], ocr_data["top"][x] + border[1], ocr_data["width"][x], ocr_data["height"][x])
        self.textLabel.setText(text.replace("\n", " "))
        self.update()

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.drawing = False
            buffer = QBuffer()
            buffer.open(QBuffer.ReadWrite)
            self.image.save(buffer, 'png')

            thread = threading.Thread(target=self.ocr, args=(buffer,))
            thread.start()

    def paintEvent(self, event):
        # Create canvas
        canvasPainter = QPainter(self)

        # Draw rectangle
        canvasPainter.drawImage(
            self.rect(), self.background, self.background.rect())
        canvasPainter.drawImage(self.rect(), self.image, self.image.rect())
        canvasPainter.drawImage(
            self.rect(), self.boundingbox, self.boundingbox.rect())
        canvasPainter.drawImage(
            self.rect(), self.foreground, self.foreground.rect())

    # Clear canvas
    def clear(self):
        # Make the canvas white
        self.image.fill(Qt.transparent)
        self.boundingbox.fill(Qt.transparent)

        self.update()

# Create and start the app
App = QApplication(sys.argv)
window = Window()
window.show()

sys.exit(App.exec())
