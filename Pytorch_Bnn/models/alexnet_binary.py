import torch.nn as nn
import torchvision.transforms as transforms
from .binarized_modules import  BinarizeLinear,BinarizeConv2d
import torch

__all__ = ['alexnet_binary']

class AlexNetOWT_BN(nn.Module):

    def __init__(self, num_classes=10):
        super(AlexNetOWT_BN, self).__init__()
        self.ratioInfl=0.0625
        self.features = nn.Sequential(
            BinarizeConv2d(1, int(64*self.ratioInfl), kernel_size=3, stride=1, padding=1),

            nn.BatchNorm2d(int(64*self.ratioInfl)),
            nn.ReLU(inplace=True),
            BinarizeConv2d(int(64*self.ratioInfl), int(64*self.ratioInfl), kernel_size=3, padding=1),
            nn.MaxPool2d(kernel_size=2, stride=2),
            nn.BatchNorm2d(int(64*self.ratioInfl)),
            nn.ReLU(inplace=True),

            BinarizeConv2d(int(64*self.ratioInfl), int(128*self.ratioInfl), kernel_size=3, padding=1),
            nn.BatchNorm2d(int(128*self.ratioInfl)),
            nn.ReLU(inplace=True),
            nn.Dropout(0.2),
            BinarizeConv2d(int(128*self.ratioInfl), int(128*self.ratioInfl), kernel_size=3, padding=1),
            nn.MaxPool2d(kernel_size=2, stride=2),
            nn.BatchNorm2d(int(128*self.ratioInfl)),
            nn.ReLU(inplace=True),
            nn.Dropout(0.2),
            BinarizeConv2d(int(128*self.ratioInfl), 16, kernel_size=3, padding=1),
            nn.AdaptiveAvgPool2d((1,1)),
            nn.BatchNorm2d(16),
            nn.ReLU(inplace=True)
            
            

        )
        self.classifier = nn.Sequential(
            BinarizeLinear(16 , 10),
            #nn.ReLU(inplace=True),
            #nn.Dropout(0.5),
            #BinarizeLinear(16, num_classes),
            #nn.BatchNorm1d(10),
            nn.LogSoftmax()
        )

        #self.regime = {
        #    0: {'optimizer': 'SGD', 'lr': 1e-2,
        #        'weight_decay': 5e-4, 'momentum': 0.9},
        #    10: {'lr': 5e-3},
        #    15: {'lr': 1e-3, 'weight_decay': 0},
        #    20: {'lr': 5e-4},
        #    25: {'lr': 1e-4}
        #}
        self.regime = {
            0: {'optimizer': 'Adam', 'lr': 5e-2},
            20: {'lr': 1e-3},
            30: {'lr': 5e-4},
            35: {'lr': 1e-4},
            40: {'lr': 1e-5}
        }
        normalize = transforms.Normalize(mean=[0.1307],
                                         std=[0.3081])
        self.input_transform = {
            'train': transforms.Compose([
               # transforms.Scale(256),
               # transforms.RandomCrop(224),
               # transforms.RandomHorizontalFlip(),
                transforms.ToTensor(),
                normalize
            ]),
            'eval': transforms.Compose([
               # transforms.Scale(256),
               # transforms.CenterCrop(224),
                transforms.ToTensor(),
                normalize
            ])
        }

    def forward(self, x):
        x = self.features(x)
        #x = x.view(-1, 256*3*3)
        x = torch.squeeze(x)
        x = self.classifier(x)
        return x


def alexnet_binary(**kwargs):
    num_classes = kwargs.get( 'num_classes', 10)
    return AlexNetOWT_BN(num_classes)