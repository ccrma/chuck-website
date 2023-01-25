﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using System;


[RequireComponent(typeof(AudioSource))]
public class ChuckInstance : MonoBehaviour {

	public bool spatialize = false;

	private bool running = false;
	private System.UInt32 myChuckId = System.UInt32.MaxValue;
	private int myNumChannels = 2;
	private int myBufferLength;
	private float[] myOutBuffer;
	private AudioSource mySource;
	private bool isMuted;
	private bool prevSpatialize;
    private int currentVar = 0;

	private AudioClip zeroClip;
	private AudioClip spatialClip;

	// Use this for initialization
	void Awake() {
		int numBuffers;
		AudioSettings.GetDSPBufferSize( out myBufferLength, out numBuffers );

		myOutBuffer = new float[myBufferLength * myNumChannels];
		myChuckId = Chuck.Manager.InitializeFilter();

		mySource = GetComponent<AudioSource>();
        mySource.loop = true;
        mySource.playOnAwake = true;

		spatialClip = (AudioClip) Resources.Load("1");
        zeroClip = (AudioClip) Resources.Load("0");

		// opposite to have first UpdateSpatialize() take effect
		prevSpatialize = !spatialize;
		UpdateSpatialize();

		running = true;
	}

	void Update()
	{
		isMuted = mySource.mute;
		UpdateSpatialize();
	}

	void UpdateSpatialize()
	{
		if( prevSpatialize == spatialize )
		{
			return;
		}

		if( spatialize )
		{
			mySource.spatialBlend = 1.0f;
			mySource.clip = spatialClip;
			mySource.Play();
		}
		else
		{
			mySource.spatialBlend = 0.0f;
			mySource.clip = zeroClip;
			mySource.Play();
		}
		prevSpatialize = spatialize;
	}

	// Update is called once per frame
	void OnAudioFilterRead(float[] data, int channels)
	{
		if( !running || isMuted )
		{
			return;
		}

		if( channels != myNumChannels )
		{
			// sadness -- num channels has changed so we must reconstruct myOutBuffer
			myNumChannels = channels;
			myOutBuffer = new float[myBufferLength * myNumChannels];
		}

		// first, run callback with data as input and myOutBuffer as output
		Chuck.Manager.ManualAudioCallback( myChuckId, data, myOutBuffer, Convert.ToUInt32( channels ) );

		// if spatializing, need to multiply output by input
		if( spatialize )
		{
			for( int i = 0; i < data.Length; i++ )
			{
				// data is passed in as inbuffer and becomes outbuffer
				// outbuffer = inbuffer * chuck_outbuffer
				data[i] *= myOutBuffer[i];
			}
		}
		// otherwise, output is already correct. either not spatializing or chuck was fed pre-spatialized audio clip
		else
		{
			// so, copy myOutBuffer back into data
			Array.Copy( myOutBuffer, data, data.Length );
		}
	}

    public string GetUniqueVariableName()
    {
        currentVar++;
        return "v" + currentVar.ToString();
    }

    public string GetUniqueVariableName( string prefix )
    {
        currentVar++;
        return prefix + currentVar.ToString();
    }

	public bool RunCode( string code )
	{
		return Chuck.Manager.RunCode( myChuckId, code );
	}

	public bool SetInt( string variableName, System.Int64 value )
	{
		return Chuck.Manager.SetInt( myChuckId, variableName, value );
	}

	public Chuck.IntCallback GetInt( string variableName, Action< System.Int64 > callback )
	{
		return Chuck.Manager.GetInt( myChuckId, variableName, callback );
	}

	public bool SetFloat( string variableName, double value )
	{
		return Chuck.Manager.SetFloat( myChuckId, variableName, value );
	}

	public Chuck.FloatCallback GetFloat( string variableName, Action< double > callback )
	{
		return Chuck.Manager.GetFloat( myChuckId, variableName, callback );
	}

	public bool SignalEvent( string variableName )
	{
		return Chuck.Manager.SignalEvent( myChuckId, variableName );
	}

	public bool BroadcastEvent( string variableName )
	{
		return Chuck.Manager.SignalEvent( myChuckId, variableName );
	}

    public void SetRunning( bool shouldRun )
    {
        running = shouldRun;
    }
}
