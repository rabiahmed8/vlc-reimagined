/*****************************************************************************
 * extended.cpp : Extended controls - Undocked
 ****************************************************************************
 * Copyright (C) 2006-2008 the VideoLAN team
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Baptiste Kempf <jb@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <cassert>

#include "extended.hpp"

#include "maininterface/compositor.hpp" /* Needed for external MI size */
#include "player/player_controller.hpp"

#include <QTabWidget>
#include <QGridLayout>
#include <QDialogButtonBox>
#include <QPushButton>
#include <QWindow>
#include <QPalette>
#include <QColor>
#include <vlc_configuration.h>
#include <vlc_modules.h>

ExtendedDialog::ExtendedDialog( qt_intf_t *_p_intf )
               : QVLCDialog( nullptr, _p_intf )
{
#ifdef __APPLE__
    setWindowFlags( Qt::Drawer );
#else
    setWindowFlags( Qt::Tool );
#endif

    setWindowOpacity( var_InheritFloat( p_intf, "qt-opacity" ) );
    setWindowTitle( qtr( "Adjustments and Effects" ) );
    setWindowRole( "vlc-extended" );

    /* Juxtopposed redesign: dark card styling and orange accents */
    {
        QPalette juxtPalette = palette();
        juxtPalette.setColor( QPalette::Window, QColor( "#1B1B1B" ) );
        juxtPalette.setColor( QPalette::Base, QColor( "#0E0E0E" ) );
        juxtPalette.setColor( QPalette::AlternateBase, QColor( "#161616" ) );
        juxtPalette.setColor( QPalette::WindowText, QColor( "#969696" ) );
        juxtPalette.setColor( QPalette::Text, QColor( "#D8D8D8" ) );
        juxtPalette.setColor( QPalette::Button, QColor( "#262626" ) );
        juxtPalette.setColor( QPalette::ButtonText, QColor( "#D8D8D8" ) );
        juxtPalette.setColor( QPalette::Highlight, QColor( "#D37918" ) );
        juxtPalette.setColor( QPalette::HighlightedText, QColor( "#161616" ) );
        setPalette( juxtPalette );
        setStyleSheet( QStringLiteral(
            "QDialog { background-color: #1B1B1B; color: #D8D8D8; font-family: Inter, Segoe UI, sans-serif; }"
            "QTabWidget::pane { border: 1px solid #232323; background-color: #161616; border-radius: 10px; padding: 6px; }"
            "QTabBar::tab { background: #1B1B1B; color: #8F8F8F; border: 1px solid #232323; border-bottom: none; border-top-left-radius: 8px; border-top-right-radius: 8px; padding: 6px 14px; margin-right: 2px; }"
            "QTabBar::tab:selected { background: #262626; color: #D8D8D8; border-color: #373737; }"
            "QTabBar::tab:hover:!selected { background: #222222; color: #B0B0B0; }"
            "QGroupBox { background-color: #161616; border: 1px solid #232323; border-radius: 10px; margin-top: 18px; padding: 12px; }"
            "QGroupBox::title { subcontrol-origin: margin; left: 14px; padding: 0 6px; color: #A0A0A0; background-color: transparent; }"
            "QPushButton { background-color: #262626; border: 1px solid #333333; border-radius: 8px; padding: 5px 14px; color: #D8D8D8; }"
            "QPushButton:hover { background-color: #303030; }"
            "QPushButton:default { background-color: #D37918; border-color: #D37918; color: #161616; font-weight: bold; }"
            "QSlider::groove:horizontal { height: 6px; background: #090909; border-radius: 3px; }"
            "QSlider::sub-page:horizontal { background: #D37918; border-radius: 3px; }"
            "QSlider::handle:horizontal { background: #D37918; width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; }"
            "QSlider::handle:horizontal:hover { background: #E08A2E; }"
            "QSlider::groove:vertical { width: 6px; background: #090909; border-radius: 3px; }"
            "QSlider::sub-page:vertical { background: #090909; border-radius: 3px; }"
            "QSlider::add-page:vertical { background: #D37918; border-radius: 3px; }"
            "QSlider::handle:vertical { background: #D37918; height: 14px; margin-left: -4px; margin-right: -4px; border-radius: 7px; }"
            "QSlider::handle:vertical:hover { background: #E08A2E; }"
            "QComboBox, QLineEdit, QSpinBox, QDoubleSpinBox { background-color: #1B1B1B; border: 1px solid #373737; border-radius: 8px; padding: 4px 8px; color: #D8D8D8; }"
            "QCheckBox::indicator { width: 16px; height: 16px; border-radius: 5px; border: 1px solid #373737; background: #1B1B1B; }"
            "QCheckBox::indicator:checked { background: #D37918; border-color: #D37918; }"
            "QRadioButton::indicator { width: 14px; height: 14px; border-radius: 7px; border: 1px solid #373737; background: #1B1B1B; }"
            "QRadioButton::indicator:checked { border: 4px solid #D37918; background: #1B1B1B; }"
        ) );
    }

    QVBoxLayout *layout = new QVBoxLayout( this );
    layout->setContentsMargins( 0, 2, 0, 1 );
    layout->setSpacing( 3 );

    mainTabW = new QTabWidget( this );

    /* AUDIO effects */
    QWidget *audioWidget = new QWidget;
    QHBoxLayout *audioLayout = new QHBoxLayout( audioWidget );
    QTabWidget *audioTab = new QTabWidget( audioWidget );

    equal = new Equalizer( p_intf, audioTab );
    connect( equal, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );
    audioTab->addTab( equal, qtr( "Equalizer" ) );

    Compressor *compres = new Compressor( p_intf, audioTab );
    connect( compres, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );
    audioTab->addTab( compres, qtr( "Compressor" ) );

    Expander *expand = new Expander( p_intf, audioTab );
    connect( expand, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );
    audioTab->addTab( expand, qtr( "Expander" ) );

    Limiter *limit = new Limiter( p_intf, audioTab );
    connect( limit, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );
    audioTab->addTab( limit, qtr( "Limiter" ) );

    Spatializer *spatial = new Spatializer( p_intf, audioTab );
    connect( spatial, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );
    audioTab->addTab( spatial, qtr( "Spatializer" ) );

    StereoWidener *stereowiden = new StereoWidener( p_intf, audioTab );
    connect( stereowiden, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );
    audioTab->addTab( stereowiden, qtr( "Stereo Widener" ) );

    QWidget *advancedTab = new QWidget;
    QGridLayout *advancedTabLayout = new QGridLayout;

    PitchShifter *pitchshifter = new PitchShifter( p_intf, audioTab );
    connect( pitchshifter, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );

    StereoPanner *stereopanner = new StereoPanner( p_intf, audioTab );
    connect( stereopanner, &AudioFilterControlWidget::configChanged, this, &ExtendedDialog::putAudioConfig );

    advancedTabLayout->setColumnStretch( 2, 10 );
    advancedTabLayout->addWidget( pitchshifter );
    advancedTabLayout->addWidget( stereopanner );

    advancedTab->setLayout( advancedTabLayout );
    audioTab->addTab( advancedTab, qtr( "Advanced" ) );

    audioLayout->addWidget( audioTab );

    mainTabW->insertTab( AUDIO_TAB, audioWidget, qtr( "Audio Effects" ) );

    /* Video Effects */
    QWidget *videoWidget = new QWidget;
    QHBoxLayout *videoLayout = new QHBoxLayout( videoWidget );
    QTabWidget *videoTab = new QTabWidget( videoWidget );

    videoEffect = new ExtVideo( p_intf, videoTab );
    connect( videoEffect, &ExtVideo::configChanged, this, &ExtendedDialog::putVideoConfig );
    videoLayout->addWidget( videoTab );
    videoTab->setSizePolicy( QSizePolicy::Preferred, QSizePolicy::Maximum );

    mainTabW->insertTab( VIDEO_TAB, videoWidget, qtr( "Video Effects" ) );

    syncW = new SyncControls( p_intf, mainTabW );
    mainTabW->insertTab( SYNCHRO_TAB, syncW, qtr( "Synchronization" ) );

    if( module_exists( "v4l2" ) )
    {
        ExtV4l2 *v4l2 = new ExtV4l2( p_intf, mainTabW );
        mainTabW->insertTab( V4L2_TAB, v4l2, qtr( "v4l2 controls" ) );
    }

    layout->addWidget( mainTabW );
    connect( mainTabW, &QTabWidget::currentChanged, this, &ExtendedDialog::currentTabChanged );

    /* Bottom buttons */
    QDialogButtonBox *buttonBox = new QDialogButtonBox( Qt::Horizontal, this );

    m_applyButton = new QPushButton( qtr("&Save"), this );
    m_applyButton->setEnabled( false );
    buttonBox->addButton( m_applyButton, QDialogButtonBox::ApplyRole );

    buttonBox->addButton(
        new QPushButton( qtr("&Close"), this ), QDialogButtonBox::RejectRole );
    layout->addWidget( buttonBox );

    connect( buttonBox, &QDialogButtonBox::rejected, this, &ExtendedDialog::close );
    connect( m_applyButton, &QPushButton::clicked, this, &ExtendedDialog::saveConfig );

    /* Restore geometry or move this dialog on the left pane of the MI */
    if( !restoreGeometry( getSettings()->value("EPanel/geometry").toByteArray() ) )
    {
        resize( QSize( 400, 280 ) );

        QWindow *window = p_intf->p_compositor->interfaceMainWindow();
        if( window && window->x() > 50 )
            move( ( window->x() - frameGeometry().width() - 10 ), window->y() );
        else
            move ( 450 , 0 );
    }

    connect( THEMIM, &PlayerController::playingStateChanged, this, &ExtendedDialog::changedItem );
}

ExtendedDialog::~ExtendedDialog()
{
    getSettings()->setValue("EPanel/geometry", saveGeometry());
}

void ExtendedDialog::showTab( int i )
{
    mainTabW->setCurrentIndex( i );
    show();
}

int ExtendedDialog::currentTab()
{
    return mainTabW->currentIndex();
}

void ExtendedDialog::changedItem( PlayerController::PlayingState i_status )
{
    if( i_status != PlayerController::PLAYING_STATE_STOPPED ) return;
    syncW->clean();
    videoEffect->clean();
}

void ExtendedDialog::currentTabChanged( int i )
{
    if( i == AUDIO_TAB || i == VIDEO_TAB )
    {
        m_applyButton->setVisible( true );
        m_applyButton->setEnabled( !m_hashConfigs[i].isEmpty() );
        m_applyButton->setFocusPolicy( Qt::StrongFocus );
    }
    else
    {
        m_applyButton->setVisible( false );
        m_applyButton->setFocusPolicy( Qt::NoFocus );
    }
}

void ExtendedDialog::putAudioConfig( const QString& name, const QVariant value )
{
    m_hashConfigs[AUDIO_TAB].insert( name, value );
    m_applyButton->setEnabled( true );
}

void ExtendedDialog::putVideoConfig( const QString& name, const QVariant value )
{
    m_hashConfigs[VIDEO_TAB].insert( name, value );
    m_applyButton->setEnabled( true );
}

void ExtendedDialog::saveConfig()
{
    assert( currentTab() == AUDIO_TAB || currentTab() == VIDEO_TAB );
    QHash<QString, QVariant> *hashConfig = &m_hashConfigs[currentTab()];

    for( QHash<QString, QVariant>::iterator i = hashConfig->begin();
         i != hashConfig->end(); ++i )
    {
        QVariant &value = i.value();
        switch( static_cast<QMetaType::Type>(value.typeId()) )
        {
            case QMetaType::QString:
                config_PutPsz( qtu(i.key()), qtu(value.toString()) );
                break;
            case QMetaType::Int:
            case QMetaType::Bool:
                config_PutInt( qtu(i.key()), value.toInt() ) ;
                break;
            case QMetaType::Double:
            case QMetaType::Float:
                config_PutFloat( qtu(i.key()), value.toFloat() ) ;
                break;
            default:
                vlc_assert_unreachable();
        }
    }
    config_SaveConfigFile( p_intf );
    hashConfig->clear();
    m_applyButton->setEnabled( false );
}
